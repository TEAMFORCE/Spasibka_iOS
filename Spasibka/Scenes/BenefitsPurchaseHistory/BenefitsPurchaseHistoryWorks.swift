//
//  BenefitsPurchaseHistoryWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 05.02.2023.
//

import StackNinja

final class BenefitsPurchaseHistory: InitClassProtocol {
   var orders: [CartItem] = []
   var market: Market? = nil
}

protocol BenefitsPurchaseHistoryWorksProtocol: StoringWorksProtocol, ApiUseCaseable, WorksProtocol
   where Store == BenefitsPurchaseHistory {}

extension BenefitsPurchaseHistoryWorksProtocol {
   var saveInput: In<Market> { .init { work in
      guard let market = work.input else { work.fail(); return }
      Self.store.market = market
      work.success()
   }.retainBy(retainer) }
   
   var getMarket: Out<Market> { .init { work in
      guard let market = Self.store.market else { work.fail(); return }
      work.success(market)
   }.retainBy(retainer) }
   
   var loadBenefitsPurchaseItems: Out<[CartItem]> { .init { [weak self] work in
      guard let marketId = Self.store.market?.id else { work.fail(); return }
      self?.apiUseCase.getOrders
         .doAsync(marketId)
         .onSuccess {
            Self.store.orders = $0
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var getOrderAtIndexWithMarket: In<Int>.Out<(Int, Market)> { .init { work in
      guard let market = Self.store.market else { work.fail(); return }
      work.success((Self.store.orders[work.in].offerId, market))
   }.retainBy(retainer) }
   
   var applyFilter: In<[SelectWrapper<OrderStatus>]>.Out<[CartItem]> { .init { work in 
      guard work.in.isEmpty == false else {
         work.success(Self.store.orders)
         return
      }
      
      let filtersToApply = work.in.map { $0.value.rawValue }
      let filteredCartItems = Self.store.orders.filter {
         filtersToApply.contains($0.orderStatus ?? 0)
      }
      
      work.success(filteredCartItems)
   }.retainBy(retainer)}
}

final class BenefitsPurchaseHistoryWorks<Asset: ASP>: BaseWorks<BenefitsPurchaseHistory, Asset>,
   BenefitsPurchaseHistoryWorksProtocol
{
   lazy var apiUseCase = Asset.apiUseCase
}
