//
//  FeedFilterPopupWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.07.2023.
//

import CoreGraphics
import StackNinja

typealias SelectableEventFilter = SelectWrapper<FeedFilterEvent>

final class FeedFilterPopupWorksStorage: InitProtocol {
   var filters = [SelectableEventFilter]()
}

protocol FeedFilterPopupWorksProtocol: StoringWorksProtocol, Assetable
where Asset: AssetProtocol, Store == FeedFilterPopupWorksStorage
{}

extension FeedFilterPopupWorksProtocol {
   var setupFilterData: In<[SelectableEventFilter]> { .init { work in
      Self.store.filters = work.in
      work.success()
   } }


   var getFilter: Out<[SelectableEventFilter]> { .init {
      let filters = Self.store.filters
      $0.success(filters)
   }}

   var updateFilterSelectAtIndex: In<Int>.Out<(item: SelectableEventFilter, index: Int)> { .init { work in
      let item = Self.store.filters[work.in]
      item.isSelected = !item.isSelected
      work.success((item: item, index: work.in))
   }.retainBy(retainer) }

   var clearFilter: Out<[SelectableEventFilter]> { .init {
      Self.store.filters.forEach { $0.isSelected = false }
      $0.success(Self.store.filters)
   }}

}

final class FeedFilterPopupWorks<Asset: ASP>: BaseWorks<FeedFilterPopupWorksStorage, Asset>,
                                              FeedFilterPopupWorksProtocol
{}
