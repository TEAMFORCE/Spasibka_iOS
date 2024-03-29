//
//  GetAuthMethodUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.10.2023.
//

import StackNinja

enum AuthMethod {
   case email
   case telegram
   case vk
   case unknown
   
   init(rawValue: String) {
      switch rawValue {
      case "EM":
         self = .email
      case "TG":
         self = .telegram
      case "VK":
         self = .vk
      default:
         self = .unknown
      }
   }
}

struct AuthMethodResponse: Decodable {
   let authMethod: String
   
   enum CodingKeys: String, CodingKey {
      case authMethod = "auth_method"
   }
}

struct GetAuthMethodUseCase: UseCaseProtocol {
   let apiWorks: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker
   
   var work: In<Void>.Out<AuthMethod> { .init { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               let headers = makeCookiedTokenHeader(token)
               let endpoint = SpasibkaEndpoints.GetAuthMethod(headers: headers)
               apiWorks.process(endpoint: endpoint)
                  .onSuccess { response in
                     guard let result = AuthMethodResponse(response.data) else {
                        work.fail()
                        return
                     }
                     work.success(AuthMethod(rawValue: result.authMethod))
                  }
                  .onFail {
                     work.fail()
                  }
            }
            .onFail {
               work.fail()
            }
      }
   }
}
