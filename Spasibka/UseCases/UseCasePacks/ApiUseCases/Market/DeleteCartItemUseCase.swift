//
//  DeleteCartItemUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.01.2023.
//

import StackNinja

struct DeleteCartItemUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let deleteCartItemApiWorker: DeleteCartItemApiWorker

   var work: Work<MarketItemRequest, Void> {
      Work<MarketItemRequest, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let request = work.input else { return nil }
               return ($0, request)
            }
            .doNext(deleteCartItemApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}

