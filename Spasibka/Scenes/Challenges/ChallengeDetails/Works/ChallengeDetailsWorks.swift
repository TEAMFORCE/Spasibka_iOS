//
//  ChallengeDetailsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.10.2022.
//

import Foundation
import StackNinja

final class ChallengeDetailsWorksStore: InitProtocol {
   var challengeDetailsInput: ChallengeDetailsInput?
   var challenge: Challenge?
   var challengeId: Int?

   var currentUserName: String?
   var currentUserId: Int?
   var currentProfileId: Int?
   var currentUserRole: String?

   var reportId: Int?

   var currentContender: Contender?
   var contenders: [Contender] = []

   var winnersReports: [ChallengeWinnerReport] = []

   var inputComment = ""

   var userLiked = false
   
   var comments: [Comment] = []
}

final class ChallengeDetailsWorks<Asset: AssetProtocol>: BaseWorks<ChallengeDetailsWorksStore, Asset> {
   let apiUseCase = Asset.apiUseCase
   let storageUseCase = Asset.safeStorageUseCase

   var getChallengeById: Out<Challenge> { .init { [weak self] work in
      guard let id = Self.store.challengeId else { return }
      self?.apiUseCase.getChallengeById
         .doAsync(id)
         .onSuccess {
            Self.store.challenge = $0
            Self.store.userLiked = $0.userLiked ?? false
            print($0.userLiked)
            work.success(result: $0)
         }
         .onFail { (error: ApiEngineError) in
            work.fail(error)
            work.fail()
         }
   } }
   
   var getChallengeResult: Work<Void, [ChallengeResult]> { .init { [weak self] work in
      guard let id = Self.store.challengeId else { return }
      self?.apiUseCase.getChallengeResult
         .doAsync(id)
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   } }
   
   var closeChallenge: Work<Void, Void> { .init { [weak self] work in
      guard let challengeId = Self.store.challengeId else { work.fail(); return }
      self?.apiUseCase.closeChallenge
         .doAsync(challengeId)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }
   
   var deleteChallenge: In<Void>.Out<Void> { .init { [weak self] work in
      guard let id = Self.store.challengeId else { work.fail(); return }
      
      self?.apiUseCase.deleteChallenge
         .doAsync(id)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }
}
