//
//  GetStickersUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 09.02.2023.
//

import StackNinja

struct GetStickersUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getStickersApiWorker: GetStickersApiWorker

   var work: Work<Void, [Sticker]> { .init { work in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .doNext(getStickersApiWorker)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   } }
}
