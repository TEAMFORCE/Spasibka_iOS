//
//  GetMarketCategoriesApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 24.01.2023.
//

import StackNinja

struct Category: Codable {
   let id: Int
   let name: String?
}

final class GetMarketCategoriesApiWorker: BaseApiWorker<(String, Int), [Category]> {
   override func doAsync(work: Wrk) {
      guard
         let request = work.input
      else {
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetMarketCategories(
            marketId: request.1,
            headers: [Config.tokenHeaderKey: request.0])
         )
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let categories: [Category] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: categories)
         }
         .catch { _ in
            work.fail()
         }
   }
}
