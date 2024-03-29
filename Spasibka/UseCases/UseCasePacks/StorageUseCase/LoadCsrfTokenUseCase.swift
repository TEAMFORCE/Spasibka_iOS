//
//  LoadCsrfTokenUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.08.2022.
//

import StackNinja

struct LoadCsrfTokenUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker

   var work: Out<String> {
      .init { work in
         safeStringStorage
            .doAsync("csrftoken")
            .onFail {
               work.fail()
            }
            .onSuccess {
               work.success(result: $0)
            }
      }
   }
}
