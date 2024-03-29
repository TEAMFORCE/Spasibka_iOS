//
//  GetTransactionStatistics.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 21.09.2022.
//

import Foundation
import StackNinja

struct LikeKind: Codable {
   let id: Int
   let code: String?
}

struct ReactItem: Codable {
   let timeOf: String
   let user: User

   enum CodingKeys: String, CodingKey {
      case timeOf = "time_of"
      case user
   }
}

struct Like: Codable {
   let likeKind: LikeKind?
   let counter: Int?
   let lastChanged: String?
   let items: [ReactItem]?

   enum CodingKeys: String, CodingKey {
      case likeKind = "like_kind"
      case counter
      case lastChanged = "last_changed"
      case items
   }
}

struct LikesCommentsStatistics: Codable {
   let transactionId: Int?
   let challengeId: Int?
   let challengeReportId: Int?
   let contentType: String
   let objectId: Int?
   let comments: Int?
   let likes: [Like]?
   
   enum CodingKeys: String, CodingKey {
      case transactionId = "transaction_id"
      case challengeId = "challenge_id"
      case challengeReportId = "challenge_report_id"
      case contentType = "content_type"
      case objectId = "object_id"
      case comments
      case likes
   }
}

struct LikesCommentsStatRequest {
   let token: String?
   let body: Body?
   struct Body: Codable {
      let transactionId: Int?
      let challengeId: Int?
      let challengeReportId: Int?
      
      init(transactionId: Int? = nil,
           challengeId: Int? = nil,
           challengeReportId: Int? = nil) {
         self.transactionId = transactionId
         self.challengeId = challengeId
         self.challengeReportId = challengeReportId
      }
      
      enum CodingKeys: String, CodingKey {
         case transactionId = "transaction_id"
         case challengeId = "challenge_id"
         case challengeReportId = "challenge_report_id"
      }
   }
}


final class GetLikesCommentsStatApiWorker: BaseApiWorker<LikesCommentsStatRequest, LikesCommentsStatistics> {
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
      let endpoint = SpasibkaEndpoints.GetLikesCommentsStat(
         headers: [Config.tokenHeaderKey: request.token.unwrap,
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
               let stat: LikesCommentsStatistics = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: stat)
         }
         .catch { _ in
            work.fail()
         }
   }
}
