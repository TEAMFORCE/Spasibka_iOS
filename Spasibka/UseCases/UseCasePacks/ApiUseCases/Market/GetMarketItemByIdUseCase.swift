//
//  GetMarketItemByIdUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 16.01.2023.
//

import Foundation
import StackNinja

struct GetMarketItemByIdUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getMarketItemByIdApiWorker: GetMarketItemByIdApiWorker

   var work: Work<MarketItemRequest, Benefit> {
      Work<MarketItemRequest, Benefit>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let request = work.input else { return nil }
               return ($0, request)
            }
            .doNext(getMarketItemByIdApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}

