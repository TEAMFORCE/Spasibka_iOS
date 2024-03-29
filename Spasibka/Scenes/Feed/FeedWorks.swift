//
//  FeedWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.08.2022.
//

import Foundation
import StackNinja

protocol FeedWorksStoreProtocol: InitClassProtocol {
   var events: [FeedEvent] { get set }
   var eventsPaginator: PaginationSystem { get }
   var tempPaginator: PaginationSystem { get }

   var filters: [FeedFilterEvent] { get set }
   var selectableFilters: [SelectableEventFilter] { get set }

   var userData: UserData? { get set }
   var currentUserName: String { get set }
   var profileId: Int? { get set }
}

protocol FeedFilteredWorksProtocol: StoringWorksProtocol, ApiUseCaseable where Store: FeedWorksStoreProtocol {}

final class FeedWorksTempStorage: InitProtocol, FeedWorksStoreProtocol {
   var events: [FeedEvent] = []
   var filters: [FeedFilterEvent] = [] {
      didSet {
         if Toggle.isBenefitsHidden {
            filters = filters.filter { $0.name != "Покупки" }
         }
      }
   }

   var selectableFilters: [SelectableEventFilter] = []
   let eventsPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
   let tempPaginator = PaginationSystem(pageSize: 20, startOffset: 1)

   var currentUserName = ""
   var userData: UserData?
   var profileId: Int?
}

extension FeedFilteredWorksProtocol {
   var initStorage: Work<UserData, Void> { .init { work in
      guard
         let user = work.unsafeInput ?? Self.store.userData
      else {
         work.fail()
         return
      }

      Self.store.userData = user
      Self.store.profileId = user.profile.id
      Self.store.currentUserName = user.profile.tgName.unwrap

      work.success()
   }.retainBy(retainer) }

   var getFilters: Out<[FeedFilterEvent]> { .init { work in
      let filters = Self.store.filters
      work.success(result: filters)
   }}

   var getActiveFilters: Out<[SelectableEventFilter]> { .init { work in
      let filters = Self.store.selectableFilters
      work.success(result: filters)
   }}

   var clearSelectedFilters: VoidWork { .init { work in
      Self.store.selectableFilters.forEach {
         $0.isSelected = true
      }
      work.success()
   }}

   var applyFilterAtIndex: In<Int> { .init { work in
      let selectableFilters = Self.store.selectableFilters
      selectableFilters.forEach {
         $0.isSelected = false
      }
      Self.store.selectableFilters[work.in].isSelected = true
      work.success()
   }}
   
   var loadFilters: VoidWork { .init { [weak self] work in
      let request = EventsRequest(filters: [])
      
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
   }}

   var loadEvents: VoidWork { .init { [weak self] work in
      var selectedFilters = Self.store.selectableFilters
         .filter(\.isSelected)
         .map(\.value.id)
      
      if selectedFilters.isEmpty {
         selectedFilters = Self.store.selectableFilters
            .map(\.value.id)
      }
      let request = EventsRequest(filters: selectedFilters)

      Self.store.eventsPaginator
         .paginationForWork(self?.apiUseCase.getEventsByFilter, withRequest: request)
         .doAsync()
         .onSuccess {
            Self.store.events.append(contentsOf: $0.array)
            Self.store.filters = $0.data?.eventTypes ?? []

            if Self.store.selectableFilters.isEmpty {
               Self.store.selectableFilters = Self.store.filters.map { SelectableEventFilter(value: $0) }
            }

            work.success()
         }
         .onFail {
            work.fail()
         }
   }}

   var getEvents: Out<[FeedEvent]> { .init { work in
      work.success(Self.store.events)
   }}

   var clearStoredEvents: VoidWork { .init { work in
      Self.store.events = []
      Self.store.eventsPaginator.reInit()
      work.success()
   }}

   var pressLikeForEvent: In<Int>.Out<(index: Int, event: FeedEvent)> { .init { [weak self] work in
      let index = work.in
      let event = Self.store.events[index]

      guard let objectType = event.eventSelectorType else { work.fail(); return }

      let isAlreadyLiked = event.userLiked == true
      let isLike = !isAlreadyLiked
      let currentLikesAmmount = Self.store.events[index].likesAmount.unwrap

      let request = LikeApiRequest(
         isLike: !isAlreadyLiked,
         id: event.id,
         objectType: objectType
      )

      self?.apiUseCase.postLike
         .doAsync(request)
         .onSuccess {
            Self.store.events[index].userLiked = isLike
            Self.store.events[index].likesAmount = (isLike ? currentLikesAmmount + 1 : currentLikesAmmount - 1)
            work.success((index: index, event: Self.store.events[index]))
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

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

   var getEventItem: MapIn<Int>.MapOut<FeedEvent> { .init { input in
      return Self.store.events[safe: input]
   } }

   var applyPopupFilters: MapIn<[SelectableEventFilter]> { .init { input in
      Self.store.selectableFilters = input
   } }
}

final class FeedWorks<Asset: AssetProtocol>: BaseWorks<FeedWorksTempStorage, Asset>, FeedFilteredWorksProtocol {
   private(set) lazy var apiUseCase = Asset.apiUseCase
}
