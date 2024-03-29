//
//  MarketWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 12.01.2023.
//

import StackNinja

struct MarketFilterPopupInput {
   let filterParams: MarketFilterParams
   let categories: [String]
}

final class MarketTempStorage: InitProtocol {
   var currentUser: UserData? = nil
   enum Filter {
      case none
      case all
      case active
   }

   var currentFilter = Filter.none

   var allOffset = 1
   var activeOffset = 1

   var isAllPaginating = false
   var isActivePaginating = false
   
   var benefits: [Benefit] = []
   var categories: [Category] = []
   
   var filterParams:MarketFilterParams = MarketFilterParams( categoryId: nil,
                                                             fromPrice: nil,
                                                             toPrice: nil,
                                                             isExpiresChecked: false,
                                                             contain: nil)
   
   var market: Market? = nil
   let marketPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
}

protocol MarketWorksProtocol: StoringWorksProtocol, Assetable
   where Asset: AssetProtocol, Store == MarketTempStorage
{
   var apiUseCase: ApiUseCase<Asset> { get }
   var userDefaultWorks: UserDefaultsWorks<Asset> { get }
}

extension MarketWorksProtocol {
   var loadFilterFromUserDefaults: Work<Void, MarketFilterParams> { .init { [weak self] work in
      guard let self else { work.fail(); return }

      self.userDefaultWorks.loadValueWork()
         .doAsync(.markerFilterParams)
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.success(MarketFilterParams(categoryId: nil,
                                            fromPrice: nil,
                                            toPrice: nil,
                                            isExpiresChecked: false,
                                            contain: nil))
         }
   }.retainBy(retainer) }

   var checkIsFilterActive: Work<Void, Bool> { .init { work in
      if
         Self.store.filterParams.fromPrice == nil,
         Self.store.filterParams.toPrice == nil,
         Self.store.filterParams.isExpiresChecked == false {
         work.success(false)
      } else {
         work.success(true)
      }
   }.retainBy(retainer) }
   
   var selectCategory: In<Int>.Out<Int> { .init { work in
      if let input = work.input {
         Self.store.filterParams.categoryId = input + 1
      }
      Self.store.benefits = []
      Self.store.marketPaginator.reInit()
      work.success(work.in)
   }.retainBy(retainer) }
   
   var selectCategoryAll: VoidWork { .init { work in
      Self.store.filterParams.categoryId = nil
      Self.store.benefits = []
      Self.store.marketPaginator.reInit()
      work.success()
   }.retainBy(retainer) }

   var getBenefits: Work<Void, [Benefit]> { .init { [weak self] work in
      guard let marketId = Self.store.market?.id else { work.fail(); return }
      var marketRequest = MarketRequest(id: marketId)
      marketRequest.minPrice = Self.store.filterParams.fromPrice
      marketRequest.maxPrice = Self.store.filterParams.toPrice
      marketRequest.contain = Self.store.filterParams.contain
      marketRequest.category = Self.store.filterParams.categoryId
      
      
      Self.store.marketPaginator
         .paginationForWork(self?.apiUseCase.getMarketItems, withRequest: marketRequest)
         .doAsync()
         .onSuccess {
            Self.store.benefits.append(contentsOf: $0)
            work.success(Self.store.benefits)
         }
         .onFail {
            work.fail()
         }
      
   }.retainBy(retainer) }

   var getBenefitById: Work<Int, Benefit> { .init { [weak self] work in
      guard
         let itemId = work.input,
         let marketId = Self.store.market?.id
      else { work.fail(); return }

      let request = MarketItemRequest(marketId: marketId, itemId: itemId)
      
      self?.apiUseCase.getMarketItemById
         .doAsync(request)
         .onSuccess {
            print($0)
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var getGetBenefitIdByIndex: Work<Int, (Int, Market)> { .init { work in
      guard let index = work.input else { work.fail(); return }
      if Self.store.benefits.indices.contains(index) {
         let id = Self.store.benefits[index].id
         if let market = Self.store.market {
            work.success((id, market))
         } else {
            work.fail()
         }
      } else {
         work.fail()
      }
   }.retainBy(retainer) }
   
   var createBenefitDetailInput: In<Int>.Out<(Int, Market)> { .init { work in
      guard
         let market = Self.store.market,
         let id = work.input
      else {
         work.fail();
         return
      }
      work.success((id, market))
   }.retainBy(retainer) }
   
   var setFilterParams: Work<MarketFilterParams, Void> { .init { work in
      guard let params = work.input else { work.fail(); return }
      Self.store.filterParams = params
      Self.store.benefits = []
      Self.store.marketPaginator.reInit()
      work.success()
   }.retainBy(retainer) }
   
   var clearFilterParamContains: VoidWork { .init { work in
      Self.store.filterParams.contain = nil
      Self.store.benefits = []
      Self.store.marketPaginator.reInit()
      work.success()
   }.retainBy(retainer) }
   
   var setFilterParamContains: Work<String, Void> { .init { work in
      guard let text = work.input else { work.fail(); return }
      Self.store.filterParams.contain = text
      Self.store.benefits = []
      Self.store.marketPaginator.reInit()
      work.success()
   }.retainBy(retainer) }
   
   var loadUserDataToStore: VoidWork { .init { [weak self] work in
      self?.userDefaultWorks.loadAssociatedValueWork()
         .doAsync(UserDefaultsValue.currentUser(nil))
         .onSuccess {
            Self.store.currentUser = $0
            Self.store.benefits = []
            Self.store.marketPaginator.reInit()
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var saveUserData: Work<UserData, Void> { .init { work in
      guard let input = work.input else { work.fail(); return }
      Self.store.currentUser = input
      Self.store.benefits = []
      Self.store.marketPaginator.reInit()
      work.success()
   }.retainBy(retainer) }
   
   var loadCategories: Work<Void, [String]> { .init { [weak self] work in
      guard let marketId = Self.store.market?.id else { work.fail(); return }
      self?.apiUseCase.getMarketCategories
         .doAsync(marketId)
         .onSuccess { categories in
            Self.store.categories = categories
            let categoryNames = categories.map { $0.name.unwrap }
            work.success(categoryNames)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var getAvailableMarkets: VoidWork { .init { [weak self] work in
      self?.apiUseCase.getAvailableMarkets
         .doAsync()
         .onSuccess {
            if let firstItem = $0.first {
               Self.store.market = firstItem
               work.success()
            } else {
               work.fail()
            }
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var getMarket: Out<Market> { .init { work in
      guard let market = Self.store.market else { work.fail(); return }
      work.success(market)
   }.retainBy(retainer) }
   
   var getFilterPopupInput: Out<MarketFilterPopupInput> { .init { work in
      let categoryNames = Self.store.categories.map{ $0.name.unwrap }
      let filterParams = Self.store.filterParams
      let result = MarketFilterPopupInput(filterParams: filterParams,
                                          categories: categoryNames)
      work.success(result)
   }.retainBy(retainer) }
}

final class MarketWorks<Asset: AssetProtocol>: BaseWorks<MarketTempStorage, Asset>, MarketWorksProtocol {
   lazy var userDefaultWorks = Asset.userDefaultsWorks
   lazy var apiUseCase = Asset.apiUseCase
}

extension MarketWorks: CheckInternetWorks {}
