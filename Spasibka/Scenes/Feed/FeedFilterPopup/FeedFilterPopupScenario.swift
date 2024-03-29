//
//  FeedFilterPopupScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.07.2023.
//

import StackNinja

struct FeedFilterPopupScenarioEvents: ScenarioEvents {

   let initializeWithFilter: Out<[SelectableEventFilter]>

   let didSelectFilterItemAtIndex: Out<Int>

   let didApplyFilterPressed: VoidWork
   let didClearFilterPressed: VoidWork
}

struct FeedFilterPopupScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = FeedFilterPopupScenarioEvents
   typealias ScenarioModelState = FeedFilterPopupState
   typealias ScenarioWorks = FeedFilterPopupWorks<Asset>
}

final class FeedFilterPopupScenario<Asset: ASP>: BaseParamsScenario<FeedFilterPopupScenarioParams<Asset>> {

   override func configure() {
      super.configure()

      events.initializeWithFilter
         .doNext(works.setupFilterData)
         .doNext(works.getFilter)
         .onSuccess(setState) { .initial($0) }

      events.didSelectFilterItemAtIndex
         .doNext(works.updateFilterSelectAtIndex)
         .onSuccess(setState) { .updateFilterItemAtIndex(item: $0, index: $1) }

      events.didApplyFilterPressed
         .doNext(works.getFilter)
         .onSuccess(setState) { .applyFilter($0) }

      events.didClearFilterPressed
         .doNext(works.clearFilter)
         .onSuccess(setState) { .applyFilter($0) }
   }
}
