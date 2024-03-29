//
//  VKChooseOrgUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 03.09.2023.
//

import ReactiveWorks

struct VKChooseOrgRequest: Codable {
   let userId: Int
   let organizationId: Int
   let accessToken: String

   enum CodingKeys: String, CodingKey {
      case userId = "user_id"
      case organizationId = "organization_id"
      case accessToken = "access_token"
   }
}

struct VKChooseOrgResponse: Decodable {
   let status: Int
   let details: String
   let token: String
   let sessionId: String

   enum CodingKeys: String, CodingKey {
      case status
      case details
      case token
      case sessionId = "sessionid"
   }
}

struct VKChooseOrgUseCase: UseCaseProtocol {
   let apiWorks: ApiWorksProtocol

   var work: In<VKChooseOrgRequest>.Out<VKChooseOrgResponse> { .init { work in
      let request = work.in
      let endpoint = SpasibkaEndpoints.VKAuthChooseOrganization(jsonData: request.jsonData)
      apiWorks.process(endpoint: endpoint)
         .onSuccess {
            guard let data = VKChooseOrgResponse($0.data) else {
               work.fail()
               return
            }

            work.success(data)
         }
         .onFail {
            work.fail()
         }
   }}
}
