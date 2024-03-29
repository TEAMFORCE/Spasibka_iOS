//
//  GetMarketItemByIdApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 16.01.2023.
//

import Foundation
import StackNinja

struct MarketItemRequest {
   let marketId: Int
   let itemId: Int
}

final class GetMarketItemByIdApiWorker: BaseApiWorker<(String, MarketItemRequest), Benefit> {
   override func doAsync(work: Wrk) {
      guard let request = work.input else { return }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetMarketItemById(
            marketId: request.1.marketId,
            id: request.1.itemId,
            headers: [Config.tokenHeaderKey: request.0]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let item: Benefit = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: item)
         }
         .catch { _ in
            work.fail()
         }
   }
}
