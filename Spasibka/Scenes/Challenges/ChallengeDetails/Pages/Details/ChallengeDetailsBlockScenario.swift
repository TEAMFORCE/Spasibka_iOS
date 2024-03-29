//
//  ChallengeDetailsBlockScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

struct ChallengeDetailsBlockScenarioEvents: ScenarioPayloadedEvents {
   let payload = Out<Challenge>()
   
//   let sendChallengeResult: VoidWork
   let reactionPressed: VoidWork
   let didTapUser: VoidWork

//   let didTapResults: VoidWork
}

final class ChallengeDetailsBlockScenario<Asset: ASP>: BasePayloadedScenario<ChallengeDetailsBlockScenarioEvents, ChallengeDetailsBlockState, ChallengeDetailsBlockWorks<Asset>> {
   override func configure() {
      super.configure()
      
      start
         .doNext(works.getChallenge)
         .onSuccess(setState) {
            .presentChallenge($0)
         }
      
//      events.sendChallengeResult
//         .doNext(works.getChallenge)
//         .onSuccess(setState) {
//            .presentSendResultScreen($0)
//         }
      
//      events.reactionPressed
//         .doNext(works.isLikedByMe)
//         .onSuccess(setState) { .buttonLikePressed(alreadySelected: $0) }
//         .doVoidNext(works.pressLike)
//         .onFail(setState) { .failedToReact(alreadySelected: $0) }
//         .doVoidNext(works.getLikesAmount)
//         .onSuccess(setState) { .updateLikesAmount($0) }
      
      events.didTapUser
         .doNext(works.getCreatorId)
         .onSuccess(setState) { .presentUserByID($0) }

//      events.didTapResults
//         .doNext(works.getChallenge)
//         .onSuccess(setState) { .presentResults($0) }
   }
}
