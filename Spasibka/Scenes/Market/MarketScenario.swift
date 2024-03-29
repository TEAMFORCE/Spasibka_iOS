//
//  MarketScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 12.01.2023.
//

import StackNinja

struct MarketScenarioInputEvents: ScenarioEvents {
//   let payload: Out<UserData>
   let didSelectBenefitIndex: Out<Int>
   let searchFilter: Out<String>
   let presentBasket: VoidWork
   let presentPurchaseHistory: VoidWork
   let requestPagination: VoidWork
   let didTapPopupFilterButton: VoidWork
   let didUpdatePopupFilterState: Out<MarketFilterParams>
   let didTapCategory: Out<Int>
   let didTapCategoryAll: VoidWork
   let clearTextField: VoidWork
   let didSelectBenefitWithId: Out<Int>
   let didTapTextFieldReturnButton: Out<String>
}

final class MarketScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<MarketScenarioInputEvents, MarketState, MarketWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()

//      events.payload
      start
         .doNext(works.loadUserDataToStore)
         .doNext(works.getAvailableMarkets)
         .onFail(setState, .hereIsEmpty)
         .doNext(works.loadFilterFromUserDefaults)
         .doNext(works.setFilterParams)
         .doNext(works.getBenefits)
         .onSuccess(setState) { .presentBenefits($0) }
         .doVoidNext(works.checkIsFilterActive)
         .onSuccess(setState) { .filterButtonSelected($0) }
         .doVoidNext(works.loadCategories)
         .onSuccess(setState) { .setCategories($0) }

      events.didSelectBenefitIndex
         .doNext(works.getGetBenefitIdByIndex)
         .onSuccess(setState) { .presentBenefitDetails($0) }
         .onFail(setState, .error)

      events.didUpdatePopupFilterState
         .doNext(works.setFilterParams)
         .doNext(works.getBenefits)
         .onSuccess(setState) { .presentBenefits($0) }

      events.searchFilter
         .doNext(works.setFilterParamContains)
         .doNext(works.getBenefits)
         .onSuccess(setState) { .presentBenefits($0) }
      
      events.presentBasket
         .doNext(works.getMarket)
         .onSuccess(setState) { .presentBasket($0) }
      
      events.presentPurchaseHistory
         .doNext(works.getMarket)
         .onSuccess(setState) { .presentPurchaseHistory($0) }
      
      events.requestPagination
         .doNext(works.getBenefits)
         .onFail(setState) { .error }
         .onSuccess(setState) { .presentBenefits($0) }
      
      events.didTapPopupFilterButton
         .doNext(works.getFilterPopupInput)
         .onSuccess(setState){ .presentFilterPopup($0) }
      
//      events.didUpdatePopupFilterState
//         .onSuccess(setState, .hidePopup)
//         .doNext(works.getBenefits)
//         .onSuccess(setState) { .presentBenefits($0) }
      events.didTapCategory
         .doNext(works.selectCategory)
         .onSuccess(setState) { .updateSelectedCatefory($0) }
         .doVoidNext(works.getBenefits)
         .onFail(setState) { .error }
         .onSuccess(setState) { .presentBenefits($0) }
      
      events.didTapCategoryAll
         .doNext(works.selectCategoryAll)
         .onSuccess(setState, .categoryAllSelected)
         .doVoidNext(works.getBenefits)
         .onFail(setState) { .error }
         .onSuccess(setState) { .presentBenefits($0) }
      
      events.clearTextField
         .doNext(works.clearFilterParamContains)
         .doVoidNext(works.getBenefits)
         .onSuccess(setState) { .presentBenefits($0) }
      
      events.didSelectBenefitWithId
         .doNext(works.createBenefitDetailInput)
         .onSuccess(setState) { .presentBenefitDetails($0) }
         .onFail(setState, .error)
      
      events.didTapTextFieldReturnButton
         .doNext(works.setFilterParamContains)
         .doNext(works.getBenefits, on: .globalBackground)
         .onSuccess(setState) { .presentBenefits($0) }
      
   }
}
