//
//  ChallengeReactionsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

final class ChallengeReactionsStore: PayloadWorkStore {
   var payload: ReactionsSceneInput?
}

final class ChallengeReactionsWorks<Asset: ASP>: BasePayloadWorks<ChallengeReactionsStore, Asset>, ApiUseCaseable {
   let apiUseCase = Asset.apiUseCase

   var getLikesByChallenge: Work<Void, [ReactItem]> { .init { [weak self] work in
      // input 1 for likes
      // input 2 for dislikes
      guard
         let payload = Self.store.payload//?.id
      else { work.fail(); return }
      var request = LikesRequestBody(likeKind: 1, includeName: true)
      switch payload {
      case let .Challenge(challengeId):
         print(challengeId)
         request.challengeId = challengeId
      case let .Transaction(transactionId):
         print(transactionId)
         request.transactionId = transactionId
      case let .ReportId(reportId):
         request.challengeReportId = reportId
      }
//      request.challengeId
//      let request = LikesRequestBody(challengeId: challengeId,
//                                     likeKind: 1,
//                                     includeName: true)
      
      self?.apiUseCase.getLikes
         .doAsync(request)
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   } }
}
