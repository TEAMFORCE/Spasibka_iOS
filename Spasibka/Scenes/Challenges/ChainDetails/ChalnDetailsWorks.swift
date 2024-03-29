//
//  ChainDetailsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.10.2022.
//

import Foundation
import StackNinja

final class ChainDetailsWorksStore: PayloadWorkStore {
   var payload: ChainDetailsInput?

   var chain: ChallengeGroup?
   var chainID: Int?
   var initialPage: ChainDetailsPageKey = .details
//   var challenge: Challenge?
//   var challengeId: Int?
//
//   var currentUserName: String?
//   var currentUserId: Int?
//   var currentProfileId: Int?
//   var currentUserRole: String?
//
//   var reportId: Int?
//
//   var currentContender: Contender?
//   var contenders: [Contender] = []
//
//   var winnersReports: [ChallengeWinnerReport] = []
//
//   var inputComment = ""
//
//   var userLiked = false
//   
//   var comments: [Comment] = []
}

final class ChainDetailsWorks<Asset: AssetProtocol>: BasePayloadWorks<ChainDetailsWorksStore, Asset> {
   let apiUseCase = Asset.apiUseCase
   let storageUseCase = Asset.safeStorageUseCase
   let userDefaultsWorks = Asset.userDefaultsWorks
   
   override var storePayload: MapInOut<Store.Payload> { .init {
      Self.store.payload = $0
      switch $0 {
      case let .byChain(chain, chapter):
         Self.store.chain = chain
         Self.store.initialPage = chapter
      case let .byId(id, chapter):
         Self.store.chainID = id
         Self.store.initialPage = chapter
      }
      return $0
   }}
   
//   var getChain: MapOut<ChallengeGroup> { .init {
//      Self.store.chain
//   } }
   
   var getChain: Out<ChallengeGroup> { .init { [weak self] work in
      guard let self else { work.fail(); return }
      if let chain = Self.store.chain {
         work.success(chain)
         return
      }
      if let chainId = Self.store.chainID {
         self.userDefaultsWorks.loadAssociatedValueWork()
            .doAsync(UserDefaultsValue.currentOrganizationID(nil))
            .onFail {
               work.fail()
            }
            .doMap {
               GroupIdRequest(organizationId: $0, groupId: chainId)
            }
            .doNext(self.apiUseCase.getChallengeGroupById)
            .onSuccess {
               Self.store.chain = $0
               work.success($0)
            }
            .onFail {
               work.fail()
            }
      }
      else {
         work.fail()
      }


   }.retainBy(retainer) }
//   
   func setChainDetails(_ chain: ChallengeGroup) {
      Self.store.chain = chain
   }
//
//   var getChallengeById: Out<Challenge> { .init { [weak self] work in
//      guard let id = Self.store.challengeId else { return }
//      self?.apiUseCase.getChallengeById
//         .doAsync(id)
//         .onSuccess {
//            Self.store.challenge = $0
//            Self.store.userLiked = $0.userLiked ?? false
//            work.success(result: $0)
//         }
//         .onFail {
//            work.fail()
//         }
//   } }
//   
//   var getChallengeResult: Work<Void, [ChallengeResult]> { .init { [weak self] work in
//      guard let id = Self.store.challengeId else { return }
//      self?.apiUseCase.getChallengeResult
//         .doAsync(id)
//         .onSuccess {
//            work.success($0)
//         }
//         .onFail {
//            work.fail()
//         }
//   } }
//   
//   var closeChallenge: Work<Void, Void> { .init { [weak self] work in
//      guard let challengeId = Self.store.challengeId else { work.fail(); return }
//      self?.apiUseCase.closeChallenge
//         .doAsync(challengeId)
//         .onSuccess {
//            work.success()
//         }
//         .onFail {
//            work.fail()
//         }
//   } }
//   
//   var deleteChallenge: In<Void>.Out<Void> { .init { [weak self] work in
//      guard let id = Self.store.challengeId else { work.fail(); return }
//      
//      self?.apiUseCase.deleteChallenge
//         .doAsync(id)
//         .onSuccess {
//            work.success()
//         }
//         .onFail {
//            work.fail()
//         }
//   } }
}
