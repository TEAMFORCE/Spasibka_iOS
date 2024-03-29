//
//  GetEventsTransactByIdApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.10.2022.
//

import Foundation
import StackNinja

struct EventTransaction: Codable {
   let id: Int
   let photo: String?
   let reason: String?
   let amount: Int
   let updatedAt: String?
   var userLiked: Bool
   
   let senderId: Int?
   let senderFirstName: String?
   let senderSurname: String?
   let senderPhoto: String?
   let senderTgName: String?
   
   let recipientId: Int?
   let recipientFirstName: String?
   let recipientSurname: String?
   let recipientPhoto: String?
   let recipientTgName: String?
   
   let isAnonymous: Bool?
   let tags: [FeedTag]?
   
   let likeAmount: Int?
   let commentsAmount: Int?
   
   let sticker: String?
   
   let photos: [String]?
   
   enum CodingKeys: String, CodingKey {
      case id
      case photo
      case reason
      case amount
      case updatedAt = "updated_at"
      case userLiked = "user_liked"
      
      case senderId = "sender_id"
      case senderFirstName = "sender_first_name"
      case senderSurname = "sender_surname"
      case senderPhoto = "sender_photo"
      case senderTgName = "sender_tg_name"
      
      case recipientId = "recipient_id"
      case recipientFirstName = "recipient_first_name"
      case recipientSurname = "recipient_surname"
      case recipientPhoto = "recipient_photo"
      case recipientTgName = "recipient_tg_name"
      
      case isAnonymous = "is_anonymous"
      case tags
      
      case likeAmount = "like_amount"
      case commentsAmount = "comments_amount"
      
      case sticker
      case photos
   }
}

final class GetEventsTransactByIdApiWorker: BaseApiWorker<RequestWithId, EventTransaction> {
   override func doAsync(work: Work<RequestWithId, EventTransaction>) {
      let cookieName = "csrftoken"
      
      guard
         let transactionRequest = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      
      let endpoint = SpasibkaEndpoints.EventsTransactById(
         id: String(transactionRequest.id),
         headers: [Config.tokenHeaderKey: transactionRequest.token,
                   "X-CSRFToken": cookie.value]
      )

      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            guard
               let transaction = EventTransaction(result.data)
            else {
               work.fail()
               return
            }
            work.success(result: transaction)
         }
         .catch { _ in
            work.fail()
         }
   }
}

