//
//  ChainDetailsModelScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja

struct ChainDetailsModelScenarioEvents: ScenarioPayloadedEvents {
   let payload = Out<ChallengeGroup>()
   
   let didTapUser: VoidWork
}

final class ChainDetailsModelScenario<Asset: ASP>: BasePayloadedScenario<
   ChainDetailsModelScenarioEvents,
   ChainDetailsModelState,
   ChainDetailsModelWorks<Asset>
> {
   override func configure() {
      super.configure()

      start
         .doNext(works.getPayload)
         .onSuccess(setState) { .presentDetails($0) }
         .doVoidNext(works.loadChainDetailsToStore)
         .doMap(works.getChainDetails)
         .onSuccess(setState) { [.presentDetails($0), .updateChainDetails($0)] }

      events.didTapUser
         .doMap(works.getAuthorID)
         .onSuccess(setState) { .presentAuthor($0) }
   }
}
