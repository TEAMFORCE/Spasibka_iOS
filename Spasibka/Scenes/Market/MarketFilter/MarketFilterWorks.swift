//
//  MarketFilterWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.01.2023.
//

import StackNinja

final class MarketFilterStorage: InitProtocol {
   var categoryId: Int?

   var fromPrice: Int?
   var toPrice: Int?

   var isExpiresChecked: Bool = false
   var categories: [String] = []
   var input: MarketFilterPopupInput? = nil
}

protocol MarketFilterWorksProtocol: StoringWorksProtocol, Assetable
   where Asset: AssetProtocol, Store == MarketFilterStorage
{
   var userDefaultWorks: UserDefaultsWorks<Asset> { get }
}

extension MarketFilterWorksProtocol {
   var setInitialFilterState: Work<Void, MarketFilterParams> { .init { [weak self] work in
      self?.userDefaultWorks.loadValueWork()
         .doAsync(.markerFilterParams)
         .onSuccess { (filter: MarketFilterParams) in
            Self.store.fromPrice = filter.fromPrice
            Self.store.toPrice = filter.toPrice
            Self.store.isExpiresChecked = filter.isExpiresChecked
            work.success(filter)
         }
         .onFail {
            work.success(.init(categoryId: nil,
                               fromPrice: nil,
                               toPrice: nil,
                               isExpiresChecked: false))
         }

   }.retainBy(retainer) }
   
   var setFilters: In<MarketFilterPopupInput>.Out<MarketFilterPopupInput> { .init { work in
      guard let input = work.input else { work.fail(); return }
      Self.store.categories = input.categories
      Self.store.fromPrice = input.filterParams.fromPrice
      Self.store.toPrice = input.filterParams.toPrice
      Self.store.categoryId = input.filterParams.categoryId
      Self.store.input = input
      work.success(input)
   }.retainBy(retainer) }
   
   var getInput: Out<MarketFilterPopupInput> { .init { work in
      guard let input = Self.store.input else { work.fail(); return }
      work.success(input)
   }.retainBy(retainer) }
   
   var updateFilterSelectAtIndex: In<Int>.Out<(item: (String, Bool), index: Int)> { .init { work in
      if Self.store.categories.indices.contains(work.in) == true {
         let name = Self.store.categories[work.in]
         
         if Self.store.categoryId == work.in + 1 {
            Self.store.categoryId = nil
            work.success((item: (name, false), index: work.in))
         } else {
            Self.store.categoryId = work.in + 1
            work.success((item: (name, true), index: work.in))
         }
      } else {
         work.fail()
      }
   }.retainBy(retainer) }


   var setFromPrice: Work<String, Void> { .init { work in
      guard let value = Int(work.unsafeInput) else {
         Self.store.fromPrice = nil
         work.fail()
         return
      }
      Self.store.fromPrice = value
      work.success()
   }.retainBy(retainer) }

   var setToPrice: Work<String, Void> { .init { work in
      guard let value = Int(work.unsafeInput) else {
         Self.store.toPrice = nil
         work.fail()
         return
      }
      Self.store.toPrice = value
      work.success()
   }.retainBy(retainer) }

   var setExpiresChecked: Work<Bool, Void> { .init { work in
      Self.store.isExpiresChecked = work.unsafeInput
      work.success()
   }.retainBy(retainer) }

   var clearFilterInUserDefaults: VoidWork {
      .init { [weak self] work in
         Self.store.fromPrice = nil
         Self.store.toPrice = nil
         Self.store.isExpiresChecked = false
         self?.userDefaultWorks.clearForKeyWork
            .doAsync(.markerFilterParams)
            .onSuccess {
               work.success()
            }
      }.retainBy(retainer)
   }

   var saveToUserDefaultsFilter: Out<MarketFilterParams> { .init { [weak self] work in
      let filterState = MarketFilterParams(
         categoryId: Self.store.categoryId,// != nil ? Self.store.categoryId.unwrap + 1: nil,
         fromPrice: Self.store.fromPrice,
         toPrice: Self.store.toPrice,
         isExpiresChecked: Self.store.isExpiresChecked
      )

      self?.userDefaultWorks.saveValueWork()
         .doAsync(.init(value: filterState, key: .markerFilterParams))
         .onSuccess {
            work.success(filterState)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
}

final class MarketFilterWorks<Asset: ASP>: BaseWorks<MarketFilterStorage, Asset>, MarketFilterWorksProtocol {
   lazy var userDefaultWorks = Asset.userDefaultsWorks
}
