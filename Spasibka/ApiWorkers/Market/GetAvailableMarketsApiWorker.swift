//
//  GetAvailableMarketsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 28.02.2023.
//

import Foundation

struct Market: Codable {
   let id: Int
   let name: String
}

final class GetAvailableMarketsApiWorker: BaseApiWorker<String, [Market]> {
   override func doAsync(work: Wrk) {
      guard
         let token = work.input
      else {
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetAvailableMarkets(
            headers: [Config.tokenHeaderKey: token])
         )
         .done { result in
            guard
               let data = result.data,
               let items: [Market] = [Market](data)
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
