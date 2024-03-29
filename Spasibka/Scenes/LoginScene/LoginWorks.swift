//
//  LoginWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 15.08.2022.
//

import Foundation
import StackNinja
import UIKit

struct AuthByNameResult {
   let authResult: Auth2Result
   let userName: String
   let sharingKey: String?
}

final class AuthWorksStorage: InitProtocol {
   var sharingKey: String?
   var loginName: String = ""
   var smsCodeInput: String?
   var auth2Result: Auth2Result?
}

protocol AuthWorksProtocol: ApiUseCaseable, StoringWorksProtocol where Store == AuthWorksStorage {}

extension AuthWorksProtocol {
   var authByName: Out<AuthByNameResult> { .init { [weak self] work in

      let request = LoginRequest(
         loginName: Self.store.loginName,
         sharedKey: Self.store.sharingKey
      )

      self?.apiUseCase.login
         .doAsync(request)
         .onSuccess {
            Self.store.auth2Result = $0
         }
         .onFail { (error: ApiEngineError) in
            work.fail(error)
         }
         .doSaveResult()
         .doInput(UserDefaultsData(value: request.loginName, key: .userPrivacyAppliedForUserName))
         .doNext(Asset.userDefaultsWorks.saveValueWork())
         .doLoadResult()
         .onSuccess {
            work.success(.init(
               authResult: $0,
               userName: Self.store.loginName,
               sharingKey: Self.store.sharingKey
            ))
         }
   }}
}

final class LoginWorks<Asset: AssetProtocol>: BaseWorks<LoginWorks.Temp, Asset>,
   InputTextCachableWorks,
   AuthWorksProtocol
{
   lazy var apiUseCase = Asset.apiUseCase

   private lazy var loginParser = TelegramNickCheckerModel()
   private lazy var smsParser = SmsCodeCheckerModel()

   typealias Temp = AuthWorksStorage

   // MARK: - Works

   var saveSceneInput: In<LoginInput>.Out<String?> { .init {
      let input = $0.in
      Self.store.loginName = input.userName ?? ""
      Self.store.sharingKey = input.sharedKey

      $0.success(input.userName)
   }}

   var loginNameInputParse: InOut<String> { .init { [weak self] work in
      self?.loginParser.work
         .retainBy(self?.retainer)
         .doAsync(work.input)
         .onSuccess {
            Self.store.loginName = $0
            work.success(result: $0)
         }
         .onFail { (text: String) in
            Self.store.loginName = ""
            work.fail(text)
         }
   }}
   
   var getFlag: Out<Bool> { .init { [weak self] work in
      self?.apiUseCase.getFlag
         .doAsync()
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var setFlag: Out<Bool> { .init { [weak self] work in
      self?.apiUseCase.setFlag
         .doAsync(true)
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   lazy var inputTextCacher = TextCachableWork(cache: Asset.service.staticTextCache, key: "LoginName")
}
