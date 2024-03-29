//
//  GetOrdersUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.01.2023.
//

import StackNinja

struct GetOrdersUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getOrdersApiWorker: GetOrdersApiWorker

   var work: Work<Int, [CartItem]> { .init { work in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .doMap {
            guard let id = work.input else { return nil }
            return ($0, id)
         }
         .doNext(getOrdersApiWorker)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   } }
}
