//
//  MarketFilterScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.01.2023.
//

import StackNinja

struct MarketFilterScenarioEvents: ScenarioEvents {
   let initializeWithFilters: Out<MarketFilterPopupInput>
   
   let didSelectFilterItemAtIndex: Out<Int>

   let didFromPriceInput: Out<String>
   let didToPriceInput: Out<String>

   let didExpiresChecked: Out<Bool>

   let didApplyFilterPressed: VoidWork
   let didClearFilterPressed: VoidWork
}

struct MarketFilterScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = MarketFilterScenarioEvents
   typealias ScenarioModelState = MarketFilterSceneState
   typealias ScenarioWorks = MarketFilterWorks<Asset>
}

final class MarketFilterScenario<Asset: ASP>: BaseParamsScenario<MarketFilterScenarioParams<Asset>> {
   override func configure() {
      super.configure()
      
      start
         .doNext(works.setInitialFilterState)
         .onSuccess(setState) { .initial($0) }
      
      events.initializeWithFilters
         .doNext(works.setFilters)
         .onSuccess(setState) { .setFilters($0) }

      events.didSelectFilterItemAtIndex
         .doSaveResult()
         .doVoidNext(works.getInput)
         .onSuccess(setState) { .updateFilters($0) }
         .doLoadResult()
         .doNext(works.updateFilterSelectAtIndex)
         .onSuccess(setState) { .updateFilterItemAtIndex(item: $0, index: $1) }

      events.didFromPriceInput
         .doNext(works.setFromPrice)

      events.didToPriceInput
         .doNext(works.setToPrice)

      events.didExpiresChecked
         .doNext(works.setExpiresChecked)

      events.didApplyFilterPressed
         .doNext(works.saveToUserDefaultsFilter)
         .onSuccess(setState) { .applyFilter($0) }

      events.didClearFilterPressed
         .doNext(works.clearFilterInUserDefaults)
         .onSuccess(setState){ .applyFilter(nil) }
   }
}
