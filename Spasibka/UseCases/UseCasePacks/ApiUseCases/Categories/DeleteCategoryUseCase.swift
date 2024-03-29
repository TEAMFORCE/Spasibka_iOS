//
//  DeleteCategoryUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.07.2023.
//

import ReactiveWorks

struct DeleteCategoryUseCase: UseCaseProtocol {
   let apiWorks: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: In<Int>.Out<Void> { .init { work in
      let request = work.in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let headers = makeCookiedTokenHeader(token)
            apiWorks.process(endpoint: SpasibkaEndpoints.DeleteCategory(
               headers: headers,
               interpolateFunction: { String(request) }
            ))
            .onSuccess { _ in
               work.success()
            }
            .onFail {
               work.fail()
            }
         }
   }}

}
