//
//  CommunityInviteUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 26.07.2023.
//

import ReactiveWorks

struct CommunityInviteUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<String, CommunityResponse> { .init { work in

      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let header = makeCookiedTokenHeader(token)
            guard
               let sharedKey = work.input
            else {
               work.fail()
               return
            }
            let endpoint = SpasibkaEndpoints.CommunityInvite(sharedKey: sharedKey, headers: header)

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
