//
//  GetUsersListApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 11.08.2022.
//

import UIKit
import StackNinja

final class GetUsersListApiWorker: BaseApiWorker<(String, Int), [FoundUser]> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"
      
      guard
         let token = work.input?.0,
         let limit = work.input?.1,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.UsersList(
            body: ["get_users": true,
                   "offset": 1,
                   "limit": limit],
            headers: [Config.tokenHeaderKey: token,
                      "X-CSRFToken": cookie.value
                     ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let usersList: [FoundUser] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: usersList)
         }
         .catch { _ in
            work.fail()
         }
   }
}
