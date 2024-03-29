//
//  GetLikesByTransactionApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 04.10.2022.
//

import Foundation
import StackNinja

struct LikesByTransactRequest {
   let token: String
   let body: LikesByTransactBody
}

struct LikesByTransactBody: Codable {
   let transactionId: Int
   let offset: Int?
   let limit: Int?
   let includeName: Bool?
   let includeCode: Bool?
   let likeKind: Int?

   enum CodingKeys: String, CodingKey {
      case transactionId = "transaction_id"
      case offset
      case limit
      case includeName = "include_name"
      case includeCode = "include_code"
      case likeKind = "like_kind"
   }

   init(transactionId: Int,
        offset: Int? = nil,
        limit: Int? = nil,
        includeName: Bool? = nil,
        includeCode: Bool? = nil,
        likeKind: Int? = nil)
   {
      self.transactionId = transactionId
      self.offset = offset
      self.limit = limit
      self.includeName = includeName
      self.includeCode = includeCode
      self.likeKind = likeKind
   }
}

struct LikesByTransacResponse: Codable {
   let transactionId: Int
   let likes: [Like]?
   
   enum CodingKeys: String, CodingKey {
      case transactionId = "transaction_id"
      case likes
   }
}

final class GetLikesByTransactionApiWorker: BaseApiWorker<LikesByTransactRequest, [Like]> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"

      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }
      let jsonData = try? JSONEncoder().encode(request.body)
      let endpoint = SpasibkaEndpoints.GetLikesByTransaction(
         headers: [Config.tokenHeaderKey: request.token,
                   "X-CSRFToken": cookie.value,
                   "Content-Type": "application/json"],
         jsonData: jsonData
      )
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let response: LikesByTransacResponse = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: response.likes ?? [])
         }
         .catch { _ in
            work.fail()
         }
   }
}
