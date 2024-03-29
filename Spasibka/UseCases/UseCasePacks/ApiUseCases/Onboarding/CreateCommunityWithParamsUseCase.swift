//
//  CreateCommunityWithParamsUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.06.2023.
//

import ReactiveWorks

struct CreateCommunityWithParamsUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<CommunityWithParamsRequest, CommunityResponse> { .init { work in
      let request = work.in

      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let header = makeCookiedTokenHeader(token)
            let body = request.dictionary ?? [:]
            let endpoint = SpasibkaEndpoints.CreateCommunityWithParams(
               headers: header, body: body
            )

            self.apiEngine
               .process(endpoint: endpoint)
               .onSuccess { result in
                  guard
                     let result = CommunityResponse(result.data)
                  else {
                     work.fail()
                     return
                  }
                  work.success(result: result)
               }
               .onFail {
                  work.fail()
               }
         }
   } }
}
