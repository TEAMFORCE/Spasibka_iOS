//
//  NotificationsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.11.2022.
//

import StackNinja

struct NotificationsEvents: ScenarioEvents {
   let requestPagination: VoidWork
}

final class NotificationsScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<NotificationsEvents, NotificationsState, NotificationsWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()

      start
         .doVoidNext(works.getNotificationsAmount)
         .onSuccess(setState) { .updateUnreadAmount($0) }
         .doVoidNext(works.loadNotificationsFromServer)
         .onFail(setState, .loadNotifyError)
         .doNext(IsNotEmpty())
         .onFail(setState, .hereIsEmpty)
         .doNext(works.getNotifySections)
         .onSuccess(setState) { .presentNotifySections($0) }
      
      events.requestPagination
         .doNext(works.loadNotificationsFromServer)
         .doNext(works.getNotifySections)
         .onSuccess(setState) { .presentNotifySections($0) }
   }
}
