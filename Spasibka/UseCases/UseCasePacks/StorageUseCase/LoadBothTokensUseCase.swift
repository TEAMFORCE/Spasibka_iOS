//
//  LoadBothTokensUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.08.2022.
//

import StackNinja

struct LoadBothTokensUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker

   var work: Out<(token: String, csrf: String)> { .init { work in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess {
            log($0)
         }
         .doSaveResult()
         .doInput("csrftoken")
         .doAsync()
         .onSuccessMixSaved { token, csrf in
            work.success(result: (token, csrf))
         }.onFail {
            work.fail()
         }
   } }
}
