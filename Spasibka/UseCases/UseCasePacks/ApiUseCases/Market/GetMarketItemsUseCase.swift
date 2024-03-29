//
//  GetMarketItemsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 12.01.2023.
//

import Foundation
import StackNinja

struct GetMarketItemsUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<PaginationWithRequest<MarketRequest>, [Benefit]> {
      Work<PaginationWithRequest<MarketRequest>, [Benefit]>() { work in
         let input = work.in
         let request = input.request
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               let endpoint2 = SpasibkaEndpoints.GetMarketItems2(headers: makeCookiedTokenHeader(token)) {
                  var res =
                     "\(request.id)/offers/?limit=\(input.limit)&offset=\(input.offset)"

                  if let category = request.category {
                     res += "&category=\(category)"
                  }
                  if let contain = request.contain {
                     res += "&contain=\(contain)"
                  }
                  if let minPrice = request.minPrice {
                     res += "&min_price=\(minPrice)"
                  }
                  if let maxPrice = request.maxPrice {
                     res += "&max_price=\(maxPrice)"
                  }
                  return res.encodeUrl
               }

               self.apiEngine
                  .process(endpoint: endpoint2)
                  .onSuccess { result in
                     let decoder = DataToDecodableParser()
                     guard
                        let data = result.data,
                        let items: [Benefit] = decoder.parse(data)
                     else {
                        work.fail()
                        return
                     }
                     work.success(result: items)
                  }
            }
      }
   }
}
