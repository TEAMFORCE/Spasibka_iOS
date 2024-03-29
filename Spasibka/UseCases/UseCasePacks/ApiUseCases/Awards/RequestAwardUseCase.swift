//
//  RequestAwardUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 25.12.2023.
//

import ReactiveWorks

struct GainAwardRequest {
   let orgId: Int
   let body: Body

   struct Body: Codable {
      let userId: String
      let awardId: Int

      enum CodingKeys: String, CodingKey {
         case userId = "user_id"
         case awardId = "award_type_id"
      }
   }
}

struct GainAwardResponse: Codable {}

struct GainAwardUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<GainAwardRequest, GainAwardResponse> { .init { work in
      let orgId = work.in.orgId
      let body = work.in.body

      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let endpoint = SpasibkaEndpoints.PostRequestAward(
               headers: makeCookiedTokenHeader(token),
               body: body.dictionary ?? [:]
            ) {
               orgId.toString
            }
            self.apiEngine
               .process(endpoint: endpoint)
               .onSuccess { result in
                  guard
                     let response = Out(result.data)
                  else {
                     work.fail()
                     return
                  }
                  work.success(result: response)
               }
               .onFail {
                  work.fail()
               }
         }
   } }
}
