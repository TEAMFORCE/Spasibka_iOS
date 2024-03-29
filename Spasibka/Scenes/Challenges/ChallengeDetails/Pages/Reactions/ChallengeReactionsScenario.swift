//
//  ChallengeReactionsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

struct ChallengeReactionsScenarioEvents: ScenarioPayloadedEvents {
   let payload = Out<ReactionsSceneInput>()
}

final class ChallengeReactionsScenario<Asset: ASP>: BasePayloadedScenario<ChallengeReactionsScenarioEvents, ChallengeReactionsState, ChallengeReactionsWorks<Asset>> {
   override func configure() {
      super.configure()

      start
         .doNext(works.getLikesByChallenge)
         .onSuccess(setState) { .presentReactions($0) }
         .onFail(setState) { .error }
   }
}
