//
//  BenefitBasketScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.01.2023.
//

import StackNinja

struct BenefitBasketScenarioScenarioInput: ScenarioEvents {
   let saveInput: Out<Market>
   let deleteItemPressed: Out<Int>
   let countPlussPressed: Out<Int>
   let countMinusPressed: Out<Int>

   let checkMarkPressed: Out<(Bool, index: Int)>
   let tableItemPressed: Out<Int>
   let buyButtonPressed: Out<Void>

   let confirmDelete: Out<Void>
   let cancelDelete: Out<Void>
}

struct BenefitBasketScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = BenefitBasketScenarioScenarioInput
   typealias ScenarioModelState = BenefitBasketState
   typealias ScenarioWorks = BenefitBasketWorks<Asset>
}

final class BenefitBasketScenario<Asset: ASP>: BaseParamsScenario<BenefitBasketScenarioParams<Asset>> {
   override func configure() {
      super.configure()

      // MARK: - load items at start with input

      events.saveInput
         .doNext(works.saveInput)
         .doNext(works.loadCartItemsFromService)
         .doVoidNext(works.getBasketItems)
         .onSuccess(setState) { .presentBasketItems($0) }
         .onFail(setState, .presentLoadingError)

      // MARK: - quantity count change

      events.countPlussPressed
         .doNext(works.increaseItemAmount)
         .onSuccess(setState) { .updateItemAtIndex($0.0, $0.1) }
         .onFail(setState) { (item: CartItem, ind: Int) in [.updateItemAtIndex(item, ind), .connectionError] }
         .doVoidNext(works.getBasketItems)
         .onSuccess(setState) { .updateSummaAndButton($0) }

      events.countMinusPressed
         .doNext(works.decreaseItemAmount)
         .onSuccess(setState) { .updateItemAtIndex($0.0, $0.1) }
         .onFail(setState) { (item: CartItem, ind: Int) in [.updateItemAtIndex(item, ind), .connectionError] }
         .doVoidNext(works.getBasketItems)
         .onSuccess(setState) { .updateSummaAndButton($0) }

      // MARK: - checkmark works

      events.checkMarkPressed
         .doNext(works.updateCheckbox)
         .onSuccess(setState) { .updateItemAtIndex($0.0, $0.1) }
         .onFail(setState) { (item: CartItem, ind: Int) in [.updateItemAtIndex(item, ind), .connectionError] }
         .doVoidNext(works.getBasketItems)
         .onSuccess(setState) { .updateSummaAndButton($0) }

      // MARK: - item select and push details

      events.tableItemPressed
         .doNext(works.getInputForBenefitDetail)
         .onSuccess(setState) {
            .presentBenefitDetails($0) }

      // MARK: - buying

      events.buyButtonPressed
         .onSuccess(setState, .presentFullScreenDarkLoader)
         .doNext(works.postOrders)
         .onSuccess(setState, .finishBuyOffers)
         .onFail(setState, .presenBuyError)

      // MARK: - deleting

      events.deleteItemPressed
         .onSuccess(setState, .presentDeleteAlert)

      Work.startVoid.retainBy(works.retainer)
         // catch index at "deleteItemPressed" and await "confirmDelete"
         .doCombine(events.deleteItemPressed, events.confirmDelete)
         .doMap { $0.0 }
         .doNext(works.deleteCartItemAtIndex)
         .onFail(setState, .deleteItemError)
         .doNext(works.getBasketItems)
         .onSuccess(setState) { .presentBasketItems($0) }

      Work.startVoid.retainBy(works.retainer)
         // catch index at "deleteItemPressed" and await "cancelDelete"
         .doCombine(events.deleteItemPressed, events.cancelDelete)
         .doVoidNext(works.getBasketItems)
         .onSuccess(setState) { .presentBasketItems($0) }
   }
}
