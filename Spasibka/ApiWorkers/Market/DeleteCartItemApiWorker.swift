//
//  DeleteCartItemApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.01.2023.
//

import Foundation
import StackNinja

final class DeleteCartItemApiWorker: BaseApiWorker<(String, MarketItemRequest), Void> {
   override func doAsync(work: Work<(String, MarketItemRequest), Void>) {
      let cookieName = "csrftoken"
      
      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      let endpoint = SpasibkaEndpoints.DeleteCartItem(
         marketId: request.1.marketId,
         itemId: request.1.itemId,
         headers: [
            Config.tokenHeaderKey: request.0,
            "X-CSRFToken": cookie.value
         ]
      )
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            work.success()
         }
         .catch { _ in
            work.fail()
         }
   }
}
