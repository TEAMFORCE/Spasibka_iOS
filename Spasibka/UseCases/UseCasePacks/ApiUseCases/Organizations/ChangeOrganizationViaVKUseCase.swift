//
//  ChangeOrganizationViaVKUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.10.2023.
//

import ReactiveWorks

struct ChangeOrganizationViaVKRequest: Encodable {
   let orgId: Int
   var vkAccessToken: String?
   
   enum CodingKeys: String, CodingKey {
      case orgId = "organization_id"
      case vkAccessToken = "access_token"
   }
}

struct VKChangeOrgAuthResult: Decodable {
   let type: String
   let isSuccess: Bool
   let token: String
   let sessionId: String
   
   enum CodingKeys: String, CodingKey {
      case type
      case isSuccess = "is_success"
      case token
      case sessionId = "sessionid"
   }
}

struct ChangeOrganizationViaVKUseCase: UseCaseProtocol {
   let apiWorks: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker
   
   var work: In<Int>.Out<VKChangeOrgAuthResult> { .init { work in
      let request = work.in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .doSaveResult()
         .doInput(Config.vkAccessTokenKey)
         .doNext(safeStringStorage)
         .onSuccessMixSaved { (vkToken: String, token: String) in
            let headers = makeCookiedTokenHeader(token)
            let jsonData = ChangeOrganizationViaVKRequest(orgId: request, vkAccessToken: vkToken).jsonData
            let endpoint = SpasibkaEndpoints.ChangeOrganization(
               headers: headers,
               jsonData: jsonData
            )
            apiWorks.process(endpoint: endpoint)
               .onSuccess {
                  guard let result = Out($0.data) else { work.fail(); return }
                  
                  work.success(result)
               }
               .onFail {
                  work.fail()
               }
         }
   }}
}
