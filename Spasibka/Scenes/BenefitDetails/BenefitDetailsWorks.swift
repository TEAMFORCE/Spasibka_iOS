//
//  BenefitDetailsWork.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 17.01.2023.
//

import StackNinja
import UIKit

protocol BenefitDetailsWorksProtocol: StoringWorksProtocol, ApiUseCaseable
   where Store == BenefitDetailsWorksStore {}

final class BenefitDetailsWorksStore: InitProtocol, ImageLoadingWorkStorageProtocol {
   var benefit: Benefit?
   var benefitId: Int?

   var inputComment = ""

   var userLiked = false

   var comments: [Comment] = []

   var isBenefitAddedToBasket = false
   var cartItemId: Int?

   //
   var loadedImage: [UIImage] = []
   
   var market: Market? = nil
}

extension BenefitDetailsWorksProtocol {
   var saveInput: Work<(Int, Market), Void> { .init { work in
      guard let input = work.input else { work.fail(); return }
      Self.store.benefitId = input.0
      Self.store.market = input.1
      work.success()
   }.retainBy(retainer) }

   var getBenefitById: Work<Void, Benefit> { .init { [weak self] work in
      guard
         let itemId = Self.store.benefitId,
         let marketId = Self.store.market?.id
      else { work.fail(); return }
      
      let request = MarketItemRequest(marketId: marketId, itemId: itemId)
      self?.apiUseCase.getMarketItemById
         .doAsync(request)
         .onSuccess {
            Self.store.benefit = $0
            if $0.orderStatus == .inCart {
               Self.store.isBenefitAddedToBasket = true
            } else {
               Self.store.isBenefitAddedToBasket = false
            }
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var addToCart: Work<Void, Void> { .init { [weak self] work in
      guard
         let offerId = Self.store.benefitId,
         let marketId = Self.store.market?.id
      else {
         work.fail(); return
      }

      let request = AddToCartRequest(offerId: offerId, quantity: 1, status: nil)
      self?.apiUseCase.addToCart
         .doAsync((request, marketId))
         .onSuccess {
            Self.store.isBenefitAddedToBasket = true
            Self.store.cartItemId = $0.id
            work.success()
         }
         .onFail {
            Self.store.isBenefitAddedToBasket = false
            work.fail()
         }
   }.retainBy(retainer) }

   var removeFromCart: Work<Void, Void> { .init { [weak self] work in
      guard
         let cartItemId = Self.store.cartItemId,
         let marketId = Self.store.market?.id
      else { work.fail(); return }
      let request = MarketItemRequest(marketId: marketId, itemId: cartItemId)
      self?.apiUseCase.deleteCartItem
         .doAsync(request)
         .onSuccess {
            Self.store.isBenefitAddedToBasket = false
            Self.store.cartItemId = nil
            work.success($0)
         }
         .onFail {
            work.fail()
         }
      work.success() // TODO: - Remove
   }.retainBy(retainer) }

   var checkIsBenefitAddedToBasket: Work<Void, Bool> { .init { work in
      work.success(Self.store.isBenefitAddedToBasket)
   }.retainBy(retainer) }
}

final class BenefitDetailsWorks<Asset: AssetProtocol>: BaseWorks<BenefitDetailsWorksStore, Asset>, BenefitDetailsWorksProtocol {
   let apiUseCase = Asset.apiUseCase
}

extension BenefitDetailsWorks: ImageLoadingWorks {}
