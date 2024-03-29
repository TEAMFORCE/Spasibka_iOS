//
//  ChainParticipantsModelScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja

struct ChainParticipantsModelScenarioEvents: ScenarioPayloadedEvents {
   let payload = Out<ChallengeGroup>()
   
   let didSelectItemAtIndex: Out<Int>
}

final class ChainParticipantsModelScenario<Asset: ASP>: BasePayloadedScenario<
   ChainParticipantsModelScenarioEvents,
   ChainParticipantsModelState,
   ChainParticipantsModelWorks<Asset>
> {
   override func configure() {
      super.configure()

      start
         .doNext(works.loadParticipantsToStore)
         .doMap(works.getParticipants)
         .onSuccess(setState) { .presentItems($0) }
      
      events.didSelectItemAtIndex
         .doMap(works.getParticipant)
         .onSuccess(setState) { .presentParticipant($0) }
   }
}
