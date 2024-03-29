//
//  VKAuth.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.09.2023.
//

import ReactiveWorks

enum VKAuthInput {
   case login(VKAuthRequest)
   case connect(VKAuthRequest)
}

struct VKAuthRequest: Codable {
   let accessToken: String
   let sharedKey: String?
   let token: String?
}

extension VKAuthRequest {
   enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
      case sharedKey = "shared_key"
      case token
   }
}

struct VKAuthResponse: Codable {
   let details: String?
   let token: String?
   let sessionId: String?
   let status: Int?
   let organizationsData: [OrganizationAuth]?

   enum CodingKeys: String, CodingKey {
      case details
      case token
      case sessionId = "sessionid"
      case status
      case organizationsData = "organizations_data"
   }
}

struct VKAuthApiWork: UseCaseProtocol {
   let apiWorks: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: In<VKAuthInput>.Out<VKAuthResponse> { .init { work in
      switch work.in {
      case let .login(request):
         let jsonData = request.jsonData
         let endPoint = SpasibkaEndpoints.VKAuth(jsonData: jsonData, headers: [:])

         apiWorks.process(endpoint: endPoint)
            .onSuccess { result in
               guard let data = VKAuthResponse(result.data) else {
                  work.fail()
                  return
               }

               work.success(data)
            }
            .onFail { (error: ApiEngineError) in
               work.fail(error)
               work.fail()
            }
      case let .connect(request):
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               let jsonData = request.jsonData
               let headers = makeCookiedTokenHeader(token)
               let endPoint = SpasibkaEndpoints.VKAuth(jsonData: jsonData, headers: headers)

               apiWorks.process(endpoint: endPoint)
                  .onSuccess { result in
                     guard let data = VKAuthResponse(result.data) else {
                        work.fail()
                        return
                     }

                     work.success(data)
                  }
                  .onFail { (error: ApiEngineError) in
                     work.fail(error)
                     work.fail()
                  }
            }
      }
   } }
}
