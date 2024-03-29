//
//  LoadTokenUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.08.2022.
//

import StackNinja

struct LoadTokenUseCase: UseCaseProtocol {
   let loadTokenWorker: LoadTokenWorker
   
   var work: Out<String> { 
      .init { work in
         loadTokenWorker
            .doAsync()
            .onFail {
               work.fail()
            }
            .onSuccess {
               work.success(result: $0)
            }
      }
   }
}

class LoadTokenWorker: WorkerProtocol {
   let safeStringStorage: StringStorageWorker
   
   init(safeStringStorage: StringStorageWorker) {
      self.safeStringStorage = safeStringStorage
   }
   
   func doAsync(work: Out<String>) {
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess {
            work.success(result: $0)
         }
   }
}
