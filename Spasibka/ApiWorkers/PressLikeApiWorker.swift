//
//  PressLikeApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.09.2022.
//

import Foundation
import StackNinja

@available(*, deprecated, message: "Use LikeRequest instead")
struct PressLikeRequest: Indexable {
   let token: String
   let body: Body

   let index: Int

   struct Body: Codable {
      let likeKind: Int
      let transactionId: Int?
      let challengeId: Int?
      let challengeReportId: Int?
      let commentId: Int?

      init(likeKind: Int,
           transactionId: Int? = nil,
           challengeId: Int? = nil,
           challengeReportId: Int? = nil,
           commentId: Int? = nil)
      {
         self.likeKind = likeKind
         self.transactionId = transactionId
         self.challengeId = challengeId
         self.challengeReportId = challengeReportId
         self.commentId = commentId
      }

      enum CodingKeys: String, CodingKey {
         case likeKind = "like_kind"
         case transactionId = "transaction"
         case challengeId = "challenge_id"
         case challengeReportId = "challenge_report_id"
         case commentId = "comment_id"
      }
   }
}

struct PressLikeResult: Codable {
   let id: Int?
   let transactionId: Int?
   let contentTypeId: Int?
   let objectId: Int?
   let likeKindId: Int?
   let isLiked: Bool?
   let dateCreated: String?
   let dateDeleted: String?
   let userId: Int?
   let likesAmount: Int?

   enum CodingKeys: String, CodingKey {
      case id
      case transactionId = "transaction_id"
      case contentTypeId = "content_type_id"
      case objectId = "object_id"
      case likeKindId = "like_kind_id"
      case isLiked = "is_liked"
      case dateCreated = "date_created"
      case dateDeleted = "date_deleted"
      case userId = "user_id"
      case likesAmount = "likes_amount"
   }
}

@available(*, deprecated, message: "Use LikeApiUseCase instead")
final class PressLikeApiWorker: BaseApiWorker<PressLikeRequest, PressLikeResult> {
   override func doAsync(work: Work<PressLikeRequest, PressLikeResult>) {
      let cookieName = "csrftoken"

      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }

      let jsonData = try? JSONEncoder().encode(request.body)

      apiEngine?
         .process(endpoint:
            SpasibkaEndpoints.PressLikeOld(
               headers: [
                  Config.tokenHeaderKey: request.token,
                  "X-CSRFToken": cookie.value,
                  "Content-Type": "application/json"
               ], jsonData: jsonData))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let result: PressLikeResult = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: result)
         }
         .catch { _ in
            work.fail()
         }
   }
}
