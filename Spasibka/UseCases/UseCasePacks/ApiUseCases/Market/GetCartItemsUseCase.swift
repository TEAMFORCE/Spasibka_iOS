//
//  GetCartItemsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.01.2023.
//

import Foundation
import StackNinja

struct GetCartItemsUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getCartItemsApiWorker: GetCartItemsApiWorker

   var work: Work<Int, [CartItem]> {
      Work<Int, [CartItem]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let id = work.input else { return nil }
               return ($0, id)
            }
            .doNext(getCartItemsApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
