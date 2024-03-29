//
//  File.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 11.08.2022.
//

import Foundation
import ReactiveWorks

struct TransactEvents: InteractorEvents {
   struct Input: InitProtocol {
      var searchUser: Event<String>?
      var sendCoins: Event<(amount: String, reason: String)>?
      var mapIndexToUser: Event<Int>? //
      var parseCoinInput: Event<String>? //
      var parseReasonInput: Event<String>? // move it
   }

   struct Output: InitProtocol {
      var balanceLoaded: Event<Balance>?
      var usersFound: Event<[FoundUser]>?
      var coinsSended: Event<(recipient: String, info: SendCoinRequest)>?
      var tokensLoaded: Event<Void>?
      var userMapped: Event<FoundUser>? //
      var coinInputParsed: Event<String>? //
      var reasonInputParsed: Event<String>? //
   }

   struct Failure: InitProtocol {
      var loadBalance: Event<Void>?
      var userSearch: Event<Void>?
      var sendCoinRequest: Event<Void>?
      var tokensLoad: Event<Void>?
      var coinInputError: Event<String>? //
      var reasonInputError: Event<String>? //
   }

   var inputs: Input = .init()
   var outputs: Output = .init()
   var failures: Failure = .init()
}

@available(*, deprecated, message: "Use SceneWorks")
final class TransactInteractor<Asset: AssetProtocol>: Interactor {
   typealias IE = TransactEvents

   var interacts: TransactEvents = .init()
   
   private lazy var apiUseCase = Asset.apiUseCase

   private lazy var searchUserWorker = SearchUserApiWorker(apiEngine: Asset.service.apiEngine)
   private lazy var safeStringStorage = StringStorageWorker(engine: Asset.service.safeStringStorage)
   private lazy var sendCoinApiWorker = SendCoinApiWorker(apiEngine: Asset.service.apiEngine)
   private lazy var loadBalanceUseCase = apiUseCase.loadBalance.work

   private lazy var coinInputParser = CoinInputCheckerModel()
   private lazy var reasonInputParser = ReasonCheckerModel()

   init() {
   }

   func start() {
      weak var slf = self

      var foundUsers: [FoundUser] = []
      var tokens: (token: String, csrf: String) = ("", "")
      var recipientID = 0
      var recipientUsername = ""

      safeStringStorage
         .doAsync("token")
         .onSuccess {
            tokens.token = $0
         }.onFail {
            slf?.sendError(\.tokensLoad, payload: ())
         }.doInput("csrftoken")
         .doNext(worker: safeStringStorage)
         .onSuccess {
            tokens.csrf = $0
            slf?.sendOutput(\.tokensLoaded, payload: ())
         }.onFail {
            slf?.sendError(\.tokensLoad, payload: ())
         }

      loadBalanceUseCase
         .doAsync()
         .onSuccess { balance in
            slf?.sendOutput(\.balanceLoaded, payload: balance)
         }.onFail {
            slf?.sendError(\.loadBalance, payload: ())
            print("balance not loaded")
         }

      onInput(\.searchUser)
         .doMap { text in
            SearchUserRequest(
               data: text,
               token: tokens.token,
               csrfToken: tokens.csrf
            )
         }.doNext(worker: searchUserWorker)
         .onSuccess { result in
            foundUsers = result
            slf?.sendOutput(\.usersFound, payload: result)
         }.onFail {
            slf?.sendError(\.userSearch, payload: ())
            print("Search user API Error")
         }

      var request: SendCoinRequest?
      onInput(\.sendCoins)
         .doMap { amount, text in
            request = SendCoinRequest(
               token: tokens.token,
               csrfToken: tokens.csrf,
               recipient: recipientID,
               amount: amount,
               reason: text
            )
            return request
         }.onFail {
            slf?.sendError(\.sendCoinRequest, payload: ())
         }.doNext(worker: sendCoinApiWorker)
         .onSuccess {
            guard let request = request else {
               return
            }

            let tuple = (recipientUsername, request)
            slf?.sendOutput(\.coinsSended, payload: tuple)
         }.onFail { (_: String) in
            slf?.sendError(\.sendCoinRequest, payload: ())
         }

      onInput(\.mapIndexToUser)
         .doMap { index in
            foundUsers[index]
         }.onSuccess { user in
            recipientUsername = user.tgName
            recipientID = user.userId
            slf?.sendOutput(\.userMapped, payload: user)
         }

      onInput(\.parseCoinInput)
         .doNext(worker: coinInputParser)
         .onSuccess { text in
            slf?.sendOutput(\.coinInputParsed, payload: text)
         }.onFail { (text: String) in
            slf?.sendError(\.coinInputError, payload: text)
         }

      onInput(\.parseReasonInput)
         .doNext(worker: reasonInputParser)
         .onSuccess { text in
            slf?.sendOutput(\.reasonInputParsed, payload: text)
         }.onFail { (text: String) in
            slf?.sendError(\.reasonInputError, payload: text)
         }
   }
}
