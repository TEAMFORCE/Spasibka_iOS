//
//  BenefitDetailsScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 17.01.2023.
//

import StackNinja

struct BenefitDetailsInputEvents: ScenarioEvents {
   let saveInput: Out<(Int, Market)>
   let addToBasket: Out<Void>
   let updateDetails: Out<Void>
}

final class BenefitDetailsScenario<Asset: AssetProtocol>: BaseWorkableScenario<BenefitDetailsInputEvents,
   BenefitDetailsState,
   BenefitDetailsWorks<Asset>>
{
   override func configure() {
      super.configure()
      
      events.saveInput
         .doNext(works.saveInput)
         .doNext(works.getBenefitById)
         .onSuccess(setState) { .presentBenefit($0) }
//         .doMap { $0.presentingImages?.compactMap(\.link) }
//         .doNext(works.loadImageGroup)
//         .onEachResult(setState) { .addLoadedImageToHeader(image: $0.0, index: $0.1) }
      
//      start
//         .doNext(works.getBenefitById)
//         .onSuccess(setState) { .presentBenefit($0) }
//         .doMap { $0.presentingImages?.compactMap(\.link) }
//         .doNext(works.loadImageGroup)
//         .onEachResult(setState) { .addLoadedImageToHeader(image: $0.0, index: $0.1) }
      
      events.addToBasket
         .onSuccess(setState, .sendButtonAwaiting)
         .doNext(works.checkIsBenefitAddedToBasket)
         .onSuccess(setState) { [weak works] result, setState in
            if result {
               works?.removeFromCart
                  .doAsync()
                  .onSuccess(setState, .sendButtonNormal)
                  .onFail(setState, .addToBasketError, .sendButtonSelected)
            } else {
               works?.addToCart
                  .doAsync()
                  .onSuccess(setState, .sendButtonSelected)
                  .onFail(setState, .addToBasketError, .sendButtonNormal)
            }
         }
      
      events.updateDetails
         .doNext(works.getBenefitById)
         .onSuccess(setState) { .presentBenefit($0) }
   }
}

