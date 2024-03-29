//
//  SetAwardToStatusApiUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.12.2023.
//

import StackNinja

struct SetAwardToStatusRequest {
   let orgId: Int
   let body: Body

   struct Body: Codable {
      let awardId: Int

      enum CodingKeys: String, CodingKey {
         case awardId = "award_id"
      }
   }
}

struct SetAwardToStatusResponse: Codable {
   let awardId: Int
   let isForProfile: Bool

   enum CodingKeys: String, CodingKey {
      case awardId = "id"
      case isForProfile = "for_profile"
   }
}

struct SetAwardToStatusUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<SetAwardToStatusRequest, SetAwardToStatusResponse> { .init { work in
      let orgId = work.in.orgId
      let body = work.in.body

      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let endpoint = SpasibkaEndpoints.PostSetAwardToStatus(
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
