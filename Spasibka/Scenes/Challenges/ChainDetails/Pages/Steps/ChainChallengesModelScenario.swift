//
//  ChainChallengesModelScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja

struct ChainChallengesModelScenarioEvents: ScenarioPayloadedEvents {
   let payload = Out<ChallengeGroup>()

   let didSelectItemAtIndex: Out<Int>
   let toggleSectionVisibility: Out<Int>
   
   let mapToSections: Out<([[Challenge]])> = .init()
}

final class ChainChallengesModelScenario<Asset: ASP>: BasePayloadedScenario<
   ChainChallengesModelScenarioEvents,
   ChainChallengesModelState,
   ChainChallengesModelWorks<Asset>
> {
   override func configure() {
      super.configure()

      start
         .doNext(works.loadChallengesChainToStore)
         .doMap(works.getChallengeSections)
         .doMap(works.storeSectionVisibilities)
         .doSendEvent(events.mapToSections)
      
      events.mapToSections
         .doZip(works.getSectionVisibilities)
         .doMap { sections, visibilities in
            return sections.enumerated().map { index, value in
               TableItemsSection(
                  items: value.splitByPairs.map { ChainCellData(itemsPair: $0) },
                  isCollapsed: visibilities[index]
               )
            }
         }
         .onSuccess(setState) { .presentChallenges($0) }

      events.didSelectItemAtIndex
         .doMap(works.getChallenge)
         .onSuccess(setState) { .presentChallenge($0) }
      
      events.toggleSectionVisibility
         .doMap(works.toggleSectionVisibility)
         .onSuccess(setState) { .toggleSectionVisibility($0) }
   }
}
