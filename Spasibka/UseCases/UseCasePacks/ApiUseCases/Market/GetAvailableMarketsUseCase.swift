//
//  GetAvailableMarketsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 28.02.2023.
//

import StackNinja

struct GetAvailableMarketsUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getAvailableMarketsApiWorker: GetAvailableMarketsApiWorker

   var work: Work<Void, [Market]> { .init { work in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .doNext(getAvailableMarketsApiWorker)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   } }
}
