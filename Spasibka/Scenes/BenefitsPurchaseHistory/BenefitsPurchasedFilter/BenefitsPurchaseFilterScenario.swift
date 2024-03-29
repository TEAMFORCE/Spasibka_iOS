//
//  BenefitsPurchaseFilterScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.01.2023.
//

import StackNinja

struct BenefitsPurchaseFilterScenarioEvents: ScenarioEvents {  
   let didSelectFilterItemAtIndex: Out<Int>
   
   let didApplyFilterPressed: VoidWork
   let didClearFilterPressed: VoidWork
}

struct BenefitsPurchaseFilterScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = BenefitsPurchaseFilterScenarioEvents
   typealias ScenarioModelState = BenefitsPurchaseFilterSceneState
   typealias ScenarioWorks = BenefitsPurchaseFilterWorks<Asset>
}

final class BenefitsPurchaseFilterScenario<Asset: ASP>: BaseParamsScenario<BenefitsPurchaseFilterScenarioParams<Asset>> {
   override func configure() {
      super.configure()
      
      start
         .doNext(works.getFilterList)
         .onSuccess(setState) { .initial($0) }
      
      events.didSelectFilterItemAtIndex
         .doNext(works.updateFilterSelectAtIndex)
         .onSuccess(setState) { .updateFilterItemAtIndex(item: $0, index: $1) }

      events.didApplyFilterPressed
         .doNext(works.getFilterList)
         .doFilter { $0.isSelected }
         .onSuccess(setState) { .applyFilter($0) }

      events.didClearFilterPressed
         .doNext(works.clearFilter)
         .onSuccess(setState) { .applyFilter([]) }
   }
}
