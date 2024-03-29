//
//  ChallengeResultsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

struct ChallengeResultsScenarioEvents: ScenarioPayloadedEvents {
   let payload = Out<Challenge>()
   
   let presentImage: Out<String>
}

final class ChallengeResultsScenario<Asset: ASP>: BasePayloadedScenario<ChallengeResultsScenarioEvents, ChallengeResultsState, ChallengeResultsWorks<Asset>> {
   override func configure() {
      super.configure()

      start
         .doNext(works.getChallengeResult)
         .onSuccess(setState) { .presentResults($0) }
         .onFail(setState) { .error }
      
      events.presentImage
         .onSuccess(setState) { .presentImageViewer($0) }
   }
}
