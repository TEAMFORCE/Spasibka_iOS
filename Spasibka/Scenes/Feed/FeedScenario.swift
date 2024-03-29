//
//  FeedScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.08.2022.
//

import StackNinja
import UIKit

struct FeedScenarioInputEvents: ScenarioEvents {
   let initStorage: Out<UserData>

   let requestPagination: VoidWork
   let requestRefresh: VoidWork
   let didSelectItemAtIndex: Out<Int>
   let didTapLikeButton: Out<Int>
   let didTapMessagesButton: Out<Int>

   let didTapFilterButtonIndex: Out<Int>
   let didTapPopupFilterButton: VoidWork
   let didUpdatePopupFilterState: Out<[SelectableEventFilter]>
   let clearSelectedFilters: VoidWork
   
   let didTapBirthdayButton: Out<Int>

   let applySelectedFiltersToScene = VoidWork()
}

final class FeedScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<FeedScenarioInputEvents, FeedSceneState, FeedWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()

      events.initStorage
         .doNext(works.initStorage)
         .doNext(works.loadFilters)
         .doNext(works.loadEvents)
         .onFail(setState, .loadFeedError)
         .doNext(works.getFilters)
         .onSuccess(setState) { .presentFilterButtons($0) }
         .doVoidNext(works.getActiveFilters)
         .onSuccess(setState) { .updateFilterButtonsState($0.map(\.isSelected)) }
         .doVoidNext(works.getEvents)
         .onSuccess(setState) { .presentEvents($0) }

      events.requestRefresh
         .doNext(works.clearStoredEvents)
         .doSendEvent(events.requestPagination)

      events.requestPagination
         .doNext(works.loadEvents)
         .onFail(setState, .loadFeedError)
         .doNext(works.getEvents)
         .onSuccess(setState) { .presentEvents($0) }

      events.didSelectItemAtIndex
         .doNext(works.getEventItem)
         .onSuccess(setState) { .routeToEvent($0) }
         .doRecover(works.getMainLinkForEventItem)
         .onSuccess(setState) { .routeToLink($0) }

      events.didTapLikeButton
         .doNext(works.pressLikeForEvent)
         .onSuccess(setState) { .updateFeedAtIndex($0, $1) }

      events.didTapMessagesButton
         .doNext(works.getEventItem)
         .onSuccess(setState) { .routeToEvent($0, true) }
         .doRecover(works.getMainLinkForEventItem)
         .onSuccess(setState) { .routeToLink($0, true) }

      events.didTapFilterButtonIndex
         .doNext(works.applyFilterAtIndex)
         .doSendEvent(events.applySelectedFiltersToScene)

      events.didTapPopupFilterButton
         .doNext(works.getFilters)
         .doVoidNext(works.getActiveFilters)
         .onSuccess(setState) { .presentFilterPopup($0) }

      events.didUpdatePopupFilterState
         .onSuccess(setState, .hidePopup)
         .doNext(works.applyPopupFilters)
         .doSendEvent(events.applySelectedFiltersToScene)

      events.applySelectedFiltersToScene
         .doNext(works.getActiveFilters)
         .onSuccess(setState) { [.updateFilterButtonsState($0.map(\.isSelected)), .loading] }
         .onSuccess(setState, .resetTable)
         .doInput(())
         .doSendEvent(events.requestRefresh)

      events.clearSelectedFilters
         .doNext(works.clearSelectedFilters)
         .doSendEvent(events.applySelectedFiltersToScene)
      
      events.didTapBirthdayButton
         .onSuccess(setState) { .presentTransactScene($0) }
   }
}
