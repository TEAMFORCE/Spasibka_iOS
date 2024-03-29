//
//  PostOrdersApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.01.2023.
//

import Foundation
import StackNinja

final class PostOrdersApiWorker: BaseApiWorker<(String, Int), Void> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"
      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.PostOrders(
            marketId: request.1,
            headers: [Config.tokenHeaderKey: request.0,
                      "X-CSRFToken": cookie.value],
            body: ["order_status" : 1])
         )
         .done { result in
            work.success()
         }
         .catch { _ in
            work.fail()
         }
   }
}
