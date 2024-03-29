//
//  BenefitsPurchaseFilterWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.01.2023.
//

import StackNinja

final class BenefitsPurchaseFilterStorage: InitProtocol {
   lazy var orderFilterList: [SelectWrapper<OrderStatus>] = OrderStatus.allCases.map { SelectWrapper(value: $0) }
}

protocol BenefitsPurchaseFilterWorksProtocol: StoringWorksProtocol, Assetable
   where Asset: AssetProtocol, Store == BenefitsPurchaseFilterStorage
{}

extension BenefitsPurchaseFilterWorksProtocol {
   var getFilterList: Out<[SelectWrapper<OrderStatus>]> { .init {
      $0.success(Self.store.orderFilterList)
   }.retainBy(retainer) }

   var updateFilterSelectAtIndex: In<Int>.Out<(item: SelectWrapper<OrderStatus>, index: Int)> { .init {
      let item = Self.store.orderFilterList[$0.in]
      Self.store.orderFilterList[$0.in].isSelected = !item.isSelected

      $0.success((item: item, index: $0.in))
   }.retainBy(retainer) }

   var clearFilter: VoidWork { .init {
      Self.store.orderFilterList.forEach { $0.isSelected = false }
      $0.success()
   }}
}

final class BenefitsPurchaseFilterWorks<Asset: ASP>: BaseWorks<BenefitsPurchaseFilterStorage, Asset>,
   BenefitsPurchaseFilterWorksProtocol
{}
