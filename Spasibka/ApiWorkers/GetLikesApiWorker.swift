//
//  GetLikesApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 22.11.2022.
//

import Foundation
import StackNinja

struct LikesRequestBody: Codable {
   var transactionId: Int?
   var challengeId: Int?
   var challengeReportId: Int?
   let commentId: Int?
   let likeKind: Int?
   let includeCode: Bool?
   let includeName: Bool?
   
   enum CodingKeys: String, CodingKey {
      case transactionId = "transaction_id"
      case challengeId = "challenge_id"
      case challengeReportId = "challenge_report_id"
      case commentId = "comment_id"
      case likeKind = "like_kind"
      case includeCode = "include_code"
      case includeName = "include_name"
   }
   
   init(transactionId: Int? = nil,
        challengeId: Int? = nil,
        challengeReportId: Int? = nil,
        commentId: Int? = nil,
        likeKind: Int? = nil,
        includeCode: Bool? = nil,
        includeName: Bool? = nil) {
      self.transactionId = transactionId
      self.challengeId = challengeId
      self.challengeReportId = challengeReportId
      self.commentId = commentId
      self.likeKind = likeKind
      self.includeCode = includeCode
      self.includeName = includeName
   }
}

struct LikesRequest {
   let token: String
   let body: LikesRequestBody
}

final class GetLikesApiWorker: BaseApiWorker<LikesRequest, [ReactItem]> {
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
      let endpoint = SpasibkaEndpoints.GetLikes(
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
            work.success(result: response.likes?.first?.items ?? [])
         }
         .catch { _ in
            work.fail()
         }
   }
}
