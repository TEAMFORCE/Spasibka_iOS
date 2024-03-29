//
//  MainMenuWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 24.01.2024.
//

import Foundation
import StackNinja

final class MainMenuWorksStorage: InitProtocol {
   var currentUser: UserData?
   var events: [FeedEvent] = []
   var recommendations: [Recommendation] = []
   var eventsPaginator = PaginationSystem(pageSize: 10, startOffset: 1)
   var tempPaginator = PaginationSystem(pageSize: 10, startOffset: 1)
   var filters: [FeedFilterEvent] = [] {
      didSet {
         if Toggle.isBenefitsHidden {
            filters = filters.filter { $0.name != "Покупки" }
         }
      }
   }
   var selectableFilters: [SelectableEventFilter] = []
}

protocol MainMenuWorksProtocol {
   var loadBalance: Out<Balance> { get }
}

final class MainMenuWorks<Asset: AssetProtocol>: BaseWorks<MainMenuWorksStorage, Asset>, MainMenuWorksProtocol, SaveLoginResultsWorksProtocol {
   internal lazy var apiUseCase = Asset.apiUseCase
   private lazy var storageUseCase = Asset.safeStorageUseCase
   private lazy var userDefaults = Asset.userDefaultsWorks

   var loadBalance: Out<Balance> {
      apiUseCase.loadBalance
   }
   
   var loadProfile: VoidWork { .init { [weak self] work in
      self?.apiUseCase.loadMyProfile
         .doAsync()
         .onSuccess { user in
            guard let self else {
               work.fail()
               return
            }

            let orgId = user.profile.organizationId
            let appLanguage = user.profile.language ?? "ru"
            Self.store.currentUser = user
            self.userDefaults.saveValueWork()
               .doAsync(UserDefaultsData(value: orgId, key: .currentOrganizationID))
               .onFail {
                  work.fail()
               }
               .doInput(UserDefaultsValue.currentUser(user))
               .doNext(self.userDefaults.saveAssociatedValueWork)
               .doInput(UserDefaultsValue.appLanguage(appLanguage))
               .doNext(self.userDefaults.saveAssociatedValueWork)
               .onSuccess {
                  work.success()
               }
               .onFail {
                  work.fail()
               }
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var loadBrandSettingsAndConfigureAppIfNeeded: Work<Void, Void> { .init { [weak self] work in
      guard let orgId = Self.store.currentUser?.profile.organizationId else {
         work.success()
         return
      }

      self?.apiUseCase.getOrganizationBrandSettings
         .doAsync(orgId)
         .doNext(BrandSettings.shared.updateSettingsWork)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }
   
   var checkThatUserDataFilledCorrectly: VoidWork { .init { work in
      guard let userData = Self.store.currentUser else {
         work.fail()
         return
      }
      let firstName = userData.profile.firstName
      let lastName = userData.profile.surName
      let isOk = firstName.unwrap.isNotEmpty && lastName.unwrap.isNotEmpty
      if isOk {
         work.success()
      } else {
         work.fail()
      }
   }.retainBy(retainer) }


   var getUserData: Out<UserData> { .init { [weak self] work in
      guard let self else { work.fail(); return }
      self.userDefaults.loadAssociatedValueWork()
         .doAsync(UserDefaultsValue.currentUser(nil))
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var getNotificationsAmount: Work<Void, Int> { .init { [weak self] work in
      self?.apiUseCase.getNotificationsAmount
         .doAsync()
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var getRecommendations: Out<[Recommendation]> { .init { [weak self] work in
      self?.apiUseCase.getRecommendations
         .doAsync()
         .onSuccess {
            Self.store.recommendations = $0
            work.success(Self.store.recommendations)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var loadFilters: VoidWork { .init { [weak self] work in
      let request = EventsRequest(filters: [])
      Self.store.tempPaginator = PaginationSystem(pageSize: 10, startOffset: 1)
      
      Self.store.tempPaginator
         .paginationForWork(self?.apiUseCase.getEventsByFilter, withRequest: request)
         .doAsync()
         .onSuccess {
            Self.store.filters = $0.data?.eventTypes ?? []
            if Self.store.selectableFilters.isEmpty {
               Self.store.selectableFilters = Self.store.filters.map {
                  let res = SelectableEventFilter(value: $0)
                  res.isSelected = true
                  return res
               }
            }
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var loadEvents: Out<[FeedEvent]> { .init { [weak self] work in
      var selectedFilters = Self.store.selectableFilters
         .filter(\.isSelected)
         .map(\.value.id)
      
      if selectedFilters.isEmpty {
         selectedFilters = Self.store.selectableFilters
            .map(\.value.id)
      }
      let request = EventsRequest(filters: selectedFilters)
      
      Self.store.eventsPaginator = PaginationSystem(pageSize: 10, startOffset: 1)
      
      Self.store.eventsPaginator
         .paginationForWork(self?.apiUseCase.getEventsByFilter, withRequest: request)
         .doAsync()
         .onSuccess {
            Self.store.events = $0.array
            work.success(Self.store.events)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var getEventItem: MapIn<Int>.MapOut<FeedEvent> { .init { input in
      return Self.store.events[safe: input]
   } }
   
   var getMainLinkForEventItem: MapIn<Int>.MapOut<URL> { .init { input in
      guard
         let event = Self.store.events[safe: input],
         let mainLink = event.mainlink,
         let url = mainLink.extractURL()
      else {
         return nil
      }

      return url
   } }
   
   var getRecommendationItem: MapIn<Int>.MapOut<Recommendation> { .init { input in
      return Self.store.recommendations[safe: input]
   } }

}
