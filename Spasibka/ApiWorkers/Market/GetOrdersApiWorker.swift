//
//  GetOrdersApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.01.2023.
//

import Foundation

final class GetOrdersApiWorker: BaseApiWorker<(String, Int), [CartItem]> {
   override func doAsync(work: Wrk) {
      guard
         let request = work.input
      else {
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetOrders(
            marketId: request.1,
            headers: [Config.tokenHeaderKey: request.0])
         )
         .done { result in
            guard
               let data = result.data,
               let items: [CartItem] = [CartItem](data)
            else {
               work.fail()
               return
            }
            work.success(result: items)
         }
         .catch { _ in
            work.fail()
         }
   }
}
