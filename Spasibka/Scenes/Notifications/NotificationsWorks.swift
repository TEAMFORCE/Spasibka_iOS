//
//  NotificationsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.11.2022.
//

import StackNinja
import UIKit

final class NotificationsStore: InitProtocol {
   var notifications: [Notification] = []

   let paginationSystem = PaginationSystem(pageSize: 20, startOffset: 1)
}

protocol NotificationsWorksProtocol: StoringWorksProtocol, Assetable
   where Asset: AssetProtocol, Store == NotificationsStore
{
   var apiUseCase: ApiUseCase<Asset> { get }

   var loadNotificationsFromServer: Work<Void, [Notification]> { get }
   var getNotifySections: Work<[Notification], [TableItemsSection]> { get }
   var getNotificationByIndex: Work<Int, Notification> { get }
   var notificationReadWithId: Work<Int, Void> { get }
}

extension NotificationsWorksProtocol {
   
   var loadNotificationsFromServer: Out<[Notification]> { .init { [weak self] work in
      Self.store.paginationSystem
         .paginationForWork(self?.apiUseCase.getNotifications)
         .doAsync()
         .onSuccess {
            Self.store.notifications.append(contentsOf: $0)
            work.success(Self.store.notifications)
         }
         .onFail {
            work.fail()
         }
   } }
   
   var getNotificationByIndex: Work<Int, Notification> {
      .init {
         $0.success(Self.store.notifications[$0.unsafeInput])
      }.retainBy(retainer)
   }

   var getNotifySections: Work<[Notification], [TableItemsSection]> { .init {
      let items = $0.unsafeInput

      guard !items.isEmpty else {
         $0.success([])
         return
      }

      var prevDay = ""

      let result = items
         .reduce([TableItemsSection]()) { result, notify in

            guard let dateString = notify.createdAt else {
               result.last?.items.append(notify)
               return result
            }

            var currentDay = dateString.dateConvertedDDMMYY
            if let date = dateString.dateConvertedToDate {
               if Calendar.current.isDateInToday(date) {
                  currentDay = Design.text.today
               } else if Calendar.current.isDateInYesterday(date) {
                  currentDay = Design.text.yesterday
               }
            }

            var result = result
            if prevDay != currentDay {
               result.append(TableItemsSection(title: currentDay))
            }

            result.last?.items.append(notify)
            prevDay = currentDay
            return result
         }

      $0.success(result)
   }.retainBy(retainer) }

   var notificationReadWithId: Work<Int, Void> { .init { [weak self] work in
      guard let id = work.input else { work.fail(); return }
      self?.apiUseCase.notificationReadWithId
         .doAsync(id)
         .onSuccess {
            work.success()
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
}

final class NotificationsWorks<Asset: AssetProtocol>: BaseWorks<NotificationsStore, Asset>,
   NotificationsWorksProtocol
{
   let apiUseCase = Asset.apiUseCase
}
