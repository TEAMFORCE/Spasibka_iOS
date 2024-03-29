//
//  BenefitsPurchaseHistoryScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 05.02.2023.
//

import StackNinja

struct BenefitsPurchaseHistoryEvents: ScenarioEvents {
   let saveInput: Out<Market>
   let didSelectItemAtIndex: Out<Int>
   let didTapFilterButton: VoidWork
   
   let didApplyFilter: Out<[SelectWrapper<OrderStatus>]>
}

struct BenefitsPurchaseHistoryScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = BenefitsPurchaseHistoryEvents
   typealias ScenarioModelState = BenefitsPurchaseHistoryState
   typealias ScenarioWorks = BenefitsPurchaseHistoryWorks<Asset>
}

final class BenefitsPurchaseHistoryScenario<Asset: ASP>: 
   BaseParamsScenario<BenefitsPurchaseHistoryScenarioParams<Asset>> {
   
   override func configure() {
      super.configure()
      
      events.saveInput
         .doNext(works.saveInput)
         .doNext(works.loadBenefitsPurchaseItems)
         .onSuccess(setState) { .presentOrders($0) }
      
//      start
//         .doNext(works.loadBenefitsPurchaseItems)
//         .onSuccess(setState) { .presentOrders($0) }
      
      events.didSelectItemAtIndex
         .doNext(works.getOrderAtIndexWithMarket)
         .onSuccess(setState) { .presentOrder($0) }
         
      
      events.didTapFilterButton
         .onSuccess(setState) { .presentFilter }
      
      events.didApplyFilter
         .doNext(works.applyFilter)
         .onSuccess(setState) { .presentOrders($0) }
   }
} 
