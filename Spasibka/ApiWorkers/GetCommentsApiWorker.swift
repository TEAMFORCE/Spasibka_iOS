//
//  GetCommentsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 26.09.2022.
//

import Foundation
import StackNinja

struct CommentsRequest {
   let token: String
   let body: CommentsRequestBody
}

struct CommentsRequestBody: Codable {
   let challengeId: Int?
   let transactionId: Int?
   let challengeReportId: Int?
   let offset: Int?
   let limit: Int?
   let includeName: Bool?
   let isReverseOrder: Bool?

   enum CodingKeys: String, CodingKey {
      case challengeId = "challenge_id"
      case transactionId = "transaction_id"
      case challengeReportId = "challenge_report_id"
      case offset
      case limit
      case includeName = "include_name"
      case isReverseOrder = "is_reverse_order"
   }

   init(transactionId: Int? = nil,
        challengeId: Int? = nil,
        challengeReportId: Int? = nil,
        offset: Int? = nil,
        limit: Int? = nil,
        includeName: Bool? = nil,
        isReverseOrder: Bool? = nil)
   {
      self.transactionId = transactionId
      self.challengeId = challengeId
      self.challengeReportId = challengeReportId
      self.offset = offset
      self.limit = limit
      self.includeName = includeName
      self.isReverseOrder = isReverseOrder
   }
}

struct User: Codable {
   let id: Int
   let name: String?
   let surname: String?
   let avatar: String?
   let tgName: String?
   
   enum CodingKeys: String, CodingKey {
      case id, name, surname, avatar
      case tgName = "tg_name"
   }
}

struct Comment: Codable {
   let id: Int
   let text: String?
   let picture: String?
   let created: String?
   let edited: String?
   let user: User?
   var userLiked: Bool?
   var likesAmount: Int?
   var isEdited: Bool?
   var canDelete: Bool?
   
   enum CodingKeys: String, CodingKey {
      case id, text, picture, created, edited, user
      case userLiked = "user_liked"
      case likesAmount = "likes_amount"
      case isEdited = "is_edited"
      case canDelete = "can_delete"
   }
   
   mutating func update(likesAmount: Int, userLiked: Bool) {
      self.likesAmount = likesAmount
      self.userLiked = userLiked
   }
}

struct CommentsResponse: Codable {
   let transactionId: Int
   let comments: [Comment]?

   enum CodingKeys: String, CodingKey {
      case transactionId = "transaction_id"
      case comments
   }
}

final class GetCommentsApiWorker: BaseApiWorker<CommentsRequest, [Comment]> {
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
      let endpoint = SpasibkaEndpoints.GetComments(
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
               let response: CommentsResponse = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: response.comments ?? [])
         }
         .catch { _ in
            work.fail()
         }
   }
}
