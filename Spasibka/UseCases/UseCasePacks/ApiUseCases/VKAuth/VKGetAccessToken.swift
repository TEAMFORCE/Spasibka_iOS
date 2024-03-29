//
//  VKGetAccessToken.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.09.2023.
//

import StackNinja

// {"access_token":"vk1.a.Nu1-EsX3ULKB9mV_6GU_AsGfSLU9ND8EaPUYjgca-MiRdgFGzEEPgiZx1uGXcFnuv0iMSsCQQOv3Sk5xeLqDimJVy1FO_oWJYptf2GmgIjojwGU3ZTfB_DCBHNIEyqFrX4kToauOCJERM9KHbZSEO7_PXVQL0ij7i_4KVYsZGZqW4On0-OWU6fA44iZYDTgP","expires_in":86400,"user_id":1451568}

// когда я выпил пива нейросеть будет за меня программировать

struct VKGetAccessTokenResponse: Decodable {
   let accessToken: String
   let expiresIn: Int
   let userId: Int
}

extension VKGetAccessTokenResponse {
   enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
      case expiresIn = "expires_in"
      case userId = "user_id"
   }
}

 struct VKGetAccessToken: UseCaseProtocol {
    let apiWorks: ApiWorksProtocol
    var work: In<String>.Out<VKGetAccessTokenResponse> { .init { work in
       let code = work.in
       let endpoint = SpasibkaEndpoints.VKGetTokenByCode {
          code
       }
       apiWorks.process(endpoint: endpoint)
          .onSuccess {
             guard let result = VKGetAccessTokenResponse($0.data) else {
                work.fail()
                return
             }

             work.success(result)
          }
          .onFail {
             work.fail()
          }
    }}
 }
