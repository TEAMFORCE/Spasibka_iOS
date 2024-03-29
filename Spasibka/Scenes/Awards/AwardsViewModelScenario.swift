//
//  AwardsViewModelScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.12.2023.
//

import StackNinja
import Foundation

struct AwardsViewModelEvents: ScenarioEvents {
   let initialMode: Out<AwardsMode>
   let didTapFilterAll: Out<Void>
   let didTapFilterWithIndex: Out<Int>
   let didTapAwardAtIndexPath: Out<IndexPath> = .init()
}

final class AwardsViewModelScenario<Asset: ASP>: BaseWorkableScenario<AwardsViewModelEvents, AwardsViewModelState, AwardsViewModelWorks<Asset>> {
   override func configure() {
      super.configure()

      events.initialMode
         .doMap(works.setInitialMode)
         .onSuccess {}

      start
         .doNext(works.loadAwards)
         .onSuccess(setState) { .presentFilterButtons($0.map(\.title)) }
         .onSuccess(setState) { .presentAwardSections($0) }

      events.didTapFilterAll
         .doMap(works.getAwardSections)
         .onSuccess(setState) { .presentAwardSections($0) }

      events.didTapFilterWithIndex
         .doMap(works.getFilteredForIndex)
         .onSuccess(setState) { .presentAwardSections($0) }

      events.didTapAwardAtIndexPath
         .doMap(works.getAwardForIndexPath)
         .onSuccess(setState) { .presentAwardDetails($0) }
   }
}
