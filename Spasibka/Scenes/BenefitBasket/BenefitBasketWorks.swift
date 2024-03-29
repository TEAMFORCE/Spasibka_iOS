//
//  BenefitBasketWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.01.2023.
//

import StackNinja

final class BenefitBasketStorage: InitClassProtocol {
   var cartItems: [CartItem] = []
   var market: Market? = nil
}

protocol BenefitBasketWorksProtocol: StoringWorksProtocol
   where Store: BenefitBasketStorage {}

extension BenefitBasketWorksProtocol {
   var getBasketItems: Work<Void, [CartItem]> { .init { work in
      work.success(Self.store.cartItems)
   }.retainBy(retainer) }
   
   var getInputForBenefitDetail: Work<Int, (Int, Market)> { .init { work in
      guard
         let index = work.input,
         let market = Self.store.market
      else { work.fail(); return }
      if Self.store.cartItems.indices.contains(index) {
         work.success((Self.store.cartItems[index].offerId, market))
      } else {
         work.fail()
      }
   }.retainBy(retainer) }
}

final class BenefitBasketWorks<Asset: ASP>: BaseWorks<BenefitBasketStorage, Asset>, BenefitBasketWorksProtocol {
   let apiUseCase = Asset.apiUseCase
   
   var saveInput: In<Market> { .init { work in
      guard let market = work.input else { work.fail(); return }
      Self.store.market = market
      work.success()
   }.retainBy(retainer) }
   
   var getMarket:  Work<Void, Market> { .init { work in
      guard let market = Self.store.market else { work.fail(); return }
      work.success(market)
   }.retainBy(retainer) }

   var loadCartItemsFromService: Work<Void, [CartItem]> { .init { [weak self] work in
      guard let marketId = Self.store.market?.id else {
         work.fail(); return
         
      }
      
      self?.apiUseCase.getCartItems
         .doAsync(marketId)
         .onSuccess {
            Self.store.cartItems = $0
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   // to delete from cart (it isn't amount decrease)
   var deleteCartItemAtIndex: Work<Int, Void> { .init { [weak self] work in
      // index in array
      let index = work.unsafeInput

      if Self.store.cartItems.indices.contains(index) {
         let itemId = Self.store.cartItems[index].id
         guard let marketId = Self.store.market?.id else { work.fail(); return }
         let request = MarketItemRequest(marketId: marketId, itemId: itemId)
         self?.apiUseCase.deleteCartItem
            .doAsync(request)
            .onSuccess {
               if Self.store.cartItems.indices.contains(index) {
                  Self.store.cartItems.remove(at: index)
                  work.success()
               } else {
                  work.fail()
               }
            }
            .onFail {
               work.fail()
            }
      } else {
         work.fail()
      }
   }.retainBy(retainer) }

   var increaseItemAmount: Work<Int, (CartItem, Int)> { .init { [weak self] work in
      guard
         let self,
         let index = work.input
      else { work.fail(); return }

      guard Self.store.cartItems.indices.contains(index) else { work.fail(); return }
      let item = Self.store.cartItems[index]
      let total = item.total ?? 0
      let newCount = (item.quantity ?? 0) + 1

      guard newCount <= total else { work.fail(); return }

      let newItem = self.updateQuantityForItem(item, count: newCount, checked: item.isChosen == true)

      Self.store.cartItems[index] = newItem

      work.success((newItem, index))

      self.updateCartItemRequest
         .doAsync(newItem)
         .onFail {
            Self.store.cartItems[index] = item
            work.fail((item, index))
         }

   }.retainBy(retainer) }

   var decreaseItemAmount: Work<Int, (CartItem, Int)> { .init { [weak self] work in
      guard
         let self,
         let index = work.input
      else { work.fail(); return }

      guard Self.store.cartItems.indices.contains(index) else { work.fail(); return }

      let item = Self.store.cartItems[index]
      let newCount = (item.quantity ?? 0) - 1

      guard newCount > 0 else { work.fail(); return }

      let newItem = self.updateQuantityForItem(item, count: newCount, checked: item.isChosen == true)

      Self.store.cartItems[index] = newItem

      work.success((newItem, index))

      self.updateCartItemRequest
         .doAsync(newItem)
         .onFail {
            Self.store.cartItems[index] = item
            work.fail((item, index))
         }

   }.retainBy(retainer) }

   var updateCheckbox: Work<(Bool, index: Int), (CartItem, Int)> { .init { [weak self] work in
      guard let self else { work.fail(); return }

      let index = work.unsafeInput.index

      guard Self.store.cartItems.indices.contains(index) else { work.fail(); return }

      let item = Self.store.cartItems[index]
      let isChoosen = item.isChosen ?? false
      let newItem = self.updateQuantityForItem(item, count: item.quantity ?? 0, checked: !isChoosen)

      Self.store.cartItems[index] = newItem

      work.success((newItem, index))

      self.updateCartItemRequest
         .doAsync(newItem)
         .onFail {
            Self.store.cartItems[index] = item
            work.fail((item, index))
         }

   }.retainBy(retainer) }

   // Private request update
   private var updateCartItemRequest: Work<CartItem, Void> { .init { [weak self] work in
      let item = work.unsafeInput

      let offerId = item.offerId
      guard
         let currentQuantity = item.quantity,
         let checkbox = item.isChosen,
         let marketId = Self.store.market?.id
      else { work.fail(); return }

      let status = checkbox == true ? "A" : "D"
      let request = AddToCartRequest(offerId: offerId,
                                     quantity: currentQuantity,
                                     status: status)
      self?.apiUseCase.addToCart
         .doAsync((request, marketId))
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }

   }.retainBy(retainer) }

   // will send request to buy selected items of basket
   var postOrders: Work<Void, Void> { .init { [weak self] work in
      guard let marketId = Self.store.market?.id else { work.fail(); return }
      self?.apiUseCase.postOrders
         .doAsync(marketId)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   // list of all orders
//   var getOrders: Work<Void, [CartItem]> { .init { [weak self] work in
//      self?.apiUseCase.getOrders
//         .doAsync()
//         .onSuccess {
//            print($0)
//            work.success($0)
//         }
//         .onFail {
//            work.fail()
//         }
//   }.retainBy(retainer) }
   private func updateQuantityForItem(_ item: CartItem, count: Int, checked: Bool) -> CartItem {
      CartItem(
         id: item.id,
         quantity: count,
         price: item.price,
         offerId: item.offerId,
         total: item.total,
         name: item.name,
         actualTo: item.actualTo,
         rest: item.rest,
         images: item.images,
         isChosen: checked,
         unavailable: item.unavailable,
         createdAt: item.createdAt,
         orderStatus: item.orderStatus,
         description: item.description
      )
   }
}
