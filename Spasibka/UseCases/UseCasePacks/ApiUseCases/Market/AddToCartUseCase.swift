//
//  AddToCartUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 24.01.2023.
//

import Foundation
import StackNinja

struct AddToCartUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let addToCartApiWorker: AddToCartApiWorker

   var work: Work<(AddToCartRequest, Int), AddToCartResponse> {
      Work<(AddToCartRequest, Int), AddToCartResponse>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let body = work.input else { return nil }
               return ($0, body.0, body.1)
            }
            .doNext(addToCartApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
