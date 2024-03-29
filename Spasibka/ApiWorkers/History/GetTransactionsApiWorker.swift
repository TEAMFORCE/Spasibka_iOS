//
//  GetTransactionsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 04.08.2022.
//

import Foundation
import StackNinja

struct Sender: Codable {
   let senderId: Int?
   let senderTgName: String?
   let senderFirstName: String?
   let senderSurname: String?
   let senderPhoto: String?
   let challengeName: String?
   let challengeId: Int?

   enum CodingKeys: String, CodingKey {
      case senderId = "sender_id"
      case senderTgName = "sender_tg_name"
      case senderFirstName = "sender_first_name"
      case senderSurname = "sender_surname"
      case senderPhoto = "sender_photo"
      case challengeName = "challenge_name"
      case challengeId = "challenge_id"
   }
}

struct Recipient: Codable {
   let recipientId: Int?
   let recipientTgName: String?
   let recipientFirstName: String?
   let recipientSurname: String?
   let recipientPhoto: String?

   enum CodingKeys: String, CodingKey {
      case recipientId = "recipient_id"
      case recipientTgName = "recipient_tg_name"
      case recipientFirstName = "recipient_first_name"
      case recipientSurname = "recipient_surname"
      case recipientPhoto = "recipient_photo"
   }
}

struct TransactionStatus: Codable {
   let id: String?
   let name: String?

   enum CodingKeys: String, CodingKey {
      case id
      case name
   }
}

struct TransactionClass: Codable {
   let id: String?
   let name: String?

   enum CodingKeys: String, CodingKey {
      case id
      case name
   }
}


struct Transaction: Codable {
   let id: Int?
   let sender: Sender?
   let senderId: Int?
   let recipient: Recipient?
   let recipientId: Int?
   let transactionStatus: TransactionStatus?
   let transactionClass: TransactionClass?
   let expireToCancel: String?
   let amount: String?
   let canUserCancel: Bool?
   let tags: [FeedTag]?
   let reasonDef: String?
   let createdAt: String?
   let updatedAt: String?
   let reason: String?
//   //
   let graceTimeout: String?
   let isAnonymous: Bool?
   let isPublic: Bool?
   let photo: String?
   let organization: Int?
   let period: Int?
   let scope: Int?
   let sticker: String?
   let photos: [String]?
//
//
//
   enum CodingKeys: String, CodingKey {
      case id
      case sender
      case senderId = "sender_id"
      case recipient
      case recipientId = "recipient_id"
      case transactionStatus = "transaction_status"
      case transactionClass = "transaction_class"
      case expireToCancel = "expire_to_cancel"
      case amount
      case canUserCancel = "can_user_cancel"
      case tags
      case reasonDef = "reason_def"
      case createdAt = "created_at"
      case updatedAt = "updated_at"
      case reason
//
      case graceTimeout = "grace_timeout"
      case isAnonymous = "is_anonymous"
      case isPublic = "is_public"
      case photo
      case organization
      case period
      case scope
      case sticker
      case photos
   }
}

struct HistoryRequest {
   let token: String?
   let pagination: Pagination?
   let sentOnly: Bool?
   let receivedOnly: Bool?

   init(token: String? = nil,
        pagination: Pagination? = nil,
        sentOnly: Bool? = nil,
        receivedOnly: Bool? = nil)
   {
      self.token = token
      self.pagination = pagination
      self.sentOnly = sentOnly
      self.receivedOnly = receivedOnly
   }
}

final class GetTransactionsApiWorker: BaseApiWorker<HistoryRequest, [Transaction]> {
   override func doAsync(work: Wrk) {
      guard let request = work.input
      else {
         work.fail()
         return
      }

      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetTransactions(
            headers: [
               Config.tokenHeaderKey: request.token.unwrap
            ],
            sentOnly: request.sentOnly,
            recievedOnly: request.receivedOnly,
            offset: request.pagination?.offset ?? 1,
            limit: request.pagination?.limit ?? 0
         ))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let transactions: [Transaction] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            print(transactions)
            work.success(result: transactions)
         }
         .catch { _ in
            work.fail()
         }
   }
}
