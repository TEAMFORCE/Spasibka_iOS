//
//  UnreadNotificationsAmountApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.11.2022.
//

import StackNinja
import Foundation

struct NotificationsAmount: Codable {
   let unreadNotifications: Int
   enum CodingKeys: String, CodingKey {
      case unreadNotifications = "unread_notifications"
   }
}

final class GetNotificationsAmountApiWorker: BaseApiWorker<String, Int> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"

      guard
         let token = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.NotificationsAmount(
            headers: [
            Config.tokenHeaderKey: token,
            "X-CSRFToken": cookie.value
         ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let notificationsAmount: NotificationsAmount = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: notificationsAmount.unreadNotifications)
         }
         .catch { _ in
            work.fail()
         }
   }
}
