//
//  G.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 09.11.2022.
//

import Foundation
import StackNinja

struct TransactionData: Codable {
   let amount: Int?
   let status: Status?
   let senderId: Int?
   let recipientId: Int?
   let senderTgName: String?
   let recipientTgName: String?
   let senderPhoto: String?
   let senderFirstname: String?
   let senderSurname: String?
   let recipientPhoto: String?
   let transactionId: Int
   let incomeTransaction: Bool
   
   enum CodingKeys: String, CodingKey {
      case amount, status
      case senderId = "sender_id"
      case recipientId = "recipient_id"
      case senderTgName = "sender_tg_name"
      case recipientTgName = "recipient_tg_name"
      case senderPhoto = "sender_photo"
      case senderFirstname = "sender_firstname"
      case senderSurname = "sender_surname"
      case recipientPhoto = "recipient_photo"
      case transactionId = "transaction_id"
      case incomeTransaction = "income_transaction"
   }
   
   enum Status: String, Codable {
      case W
      case A
      case D
      case C
      case R
      case G
   }
}

struct ChallengeData: Codable {
   let challengeId: Int
   let challengeName: String?
   let creatorTgName: String?
   let creatorFirstName: String?
   let creatorSurname: String?
   let creatorPhoto: String?
   
   enum CodingKeys: String, CodingKey {
      case challengeId = "challenge_id"
      case challengeName = "challenge_name"
      case creatorTgName = "creator_tg_name"
      case creatorFirstName = "creator_first_name"
      case creatorSurname = "creator_surname"
      case creatorPhoto = "creator_photo"
   }
}

struct ReportData: Codable {
   let reportId: Int
   let challengeId: Int
   let challengeName: String
   let reportSenderPhoto: String?
   let reportSenderSurname: String?
   let reportSenderTgName: String?
   let reportSenderFirstName: String?
   
   enum CodingKeys: String, CodingKey {
      case reportId = "report_id"
      case challengeId = "challenge_id"
      case challengeName = "challenge_name"
      case reportSenderPhoto = "report_sender_photo"
      case reportSenderSurname = "report_sender_surname"
      case reportSenderTgName = "report_sender_tg_name"
      case reportSenderFirstName = "report_sender_first_name"
   }
}

struct WinnerData: Codable {
   let prize: Int
   let challengeId: Int
   let challengeName: String?
   let challengeReportId: Int
   
   enum CodingKeys: String, CodingKey {
      case prize
      case challengeId = "challenge_id"
      case challengeName = "challenge_name"
      case challengeReportId = "challenge_report_id"
   }
}

struct LikeData: Codable {
   let transactionId: Int?
   let commentId: Int?
   let challengeId: Int?
   let reactionFromPhoto: String?
   let reactionFromTgName: String?
   let reactionFromSurname: String?
   let reactionFromFirstName: String?
   
   enum CodingKeys: String, CodingKey {
      case transactionId = "transaction_id"
      case commentId = "comment_id"
      case challengeId = "challenge_id"
      case reactionFromPhoto = "reaction_from_photo"
      case reactionFromTgName = "reaction_from_tg_name"
      case reactionFromSurname = "reaction_from_surname"
      case reactionFromFirstName = "reaction_from_first_name"
   }
}

struct CommentData: Codable {
   let transactionId: Int?
   let challengeId: Int?
   let commentFromPhoto: String?
   let commentFromTgName: String?
   let commentFromSurname: String?
   let commentFromFirstName: String?
   
   enum CodingKeys: String, CodingKey {
      case transactionId = "transaction_id"
      case challengeId = "challenge_id"
      case commentFromPhoto = "comment_from_photo"
      case commentFromTgName = "comment_from_tg_name"
      case commentFromSurname = "comment_from_surname"
      case commentFromFirstName = "comment_from_first_name"
   }
}

struct OrderData: Codable {
   let orderId: Int?
   let offerName: String?
   let customerId: Int?
   let customerName: String?
   let marketplaceId: Int?
   let marketplaceName: String?
   
   enum CodingKeys: String, CodingKey {
      case orderId = "order_id"
      case offerName = "offer_name"
      case customerId = "customer_id"
      case customerName = "customer_name"
      case marketplaceId = "marketplace_id"
      case marketplaceName = "marketplace_name"
   }
}

struct QuestionnaireData: Codable {
   let mode: Int?
   let finishedAt: String?
   let questionnaireId: Int?
   let questionnaireTitle: String?
   
   enum CodingKeys: String, CodingKey {
      case mode
      case finishedAt = "finished_at"
      case questionnaireId = "questionnaire_id"
      case questionnaireTitle = "questionnaire_title"
   }
}

struct ChallengeEndingData: Codable {
   let challengeId: Int?
   let challengeName: String?
   
   enum CodingKeys: String, CodingKey {
      case challengeId = "challenge_id"
      case challengeName = "challenge_name"
   }
}
enum NotificationType: String, Codable {
   case transactAdded = "T" // Transaction event
   case challengeCreated = "H" // Challenge created
   case commentAdded = "C" // Comment added
   case likeAdded = "L" // Some liked
   case challengeWin = "W" // Challenge Win
   case newReportToChallenge = "R" // new report to challenge
   case marketplace = "M"
   case challengeFinished = "E" // challenge finished
   case questionnaire = "Q" // questionnaire
}

struct Notification: Codable {
   let id: Int
   let type: NotificationType?
   let theme: String
   let transactionData: TransactionData?
   let challengeData: ChallengeData?
   let reportData: ReportData?
   let winnerData: WinnerData?
   let likeData: LikeData?
   let commentData: CommentData?
   let orderData: OrderData?
   let challengeEndingData: ChallengeEndingData?
   let questionnaireData: QuestionnaireData?
   
   let read: Bool
   let createdAt: String?
   let updatedAt: String?
   
   
   enum CodingKeys: String, CodingKey {
      case id, type, theme
      case transactionData = "transaction_data"
      case challengeData = "challenge_data"
      case reportData = "report_data"
      case winnerData = "winner_data"
      case likeData = "like_data"
      case commentData = "comment_data"
      case orderData = "order_data"
      case challengeEndingData = "challenge_ending_data"
      case questionnaireData = "questionnaire_data"
      
      case read
      case createdAt = "created_at"
      case updatedAt = "updated_at"
   }

}

final class GetNotificationsApiWorker: BaseApiWorker<(String, Pagination), [Notification]> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"

      guard
         let token = work.input?.0,
         let pagination = work.input?.1,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.Notifications(
            offset: pagination.offset,
            limit: pagination.limit,
            headers: [
            Config.tokenHeaderKey: token,
            "X-CSRFToken": cookie.value
         ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let notifications: [Notification] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: notifications)
         }
         .catch { _ in
            work.fail()
         }
   }
}
