//
//  CommonEndPoints.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.12.2022.
//

import Foundation

// Api Endpoints
enum CommonEndpoints {
   //
   struct locationByIpEndpoint: EndpointProtocol {
      //
      let method = HTTPMethod.get

      var endPoint: String { "http://ip-api.com/json/" }

      let body: [String: Any] = [:]
   }
}
