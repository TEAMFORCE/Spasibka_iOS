//
//  GetStickerpacksUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 09.02.2023.
//

import StackNinja

struct GetStickerpacksUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getStickerpacksApiWorker: GetStickerpacksApiWorker

   var work: Work<Void, [Stickerpack]> { .init { work in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .doNext(getStickerpacksApiWorker)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   } }
}
