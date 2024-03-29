//
//  GetChallengeWinnersReportsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.10.2022.
//

import Foundation
import StackNinja
struct ChallengeWinnerReport: Codable {
   let id: Int
   let nickname: String?
   let awardedAt: String
   let photo: String?
   let challengeId: Int
   let participantId: Int
   let participantPhoto: String?
   let participantName: String?
   let participantSurname: String?
   var userLiked: Bool?
   let commentsAmount: Int?
   var likesAmount: Int?
   let award: Int?
   
   enum CodingKeys: String, CodingKey {
      case id, nickname, photo, award
      case awardedAt = "awarded_at"
      case challengeId = "challenge_id"
      case participantId = "participant_id"
      case participantPhoto = "participant_photo"
      case participantName = "participant_name"
      case participantSurname = "participant_surname"
      case userLiked = "user_liked"
      case commentsAmount = "comments_amount"
      case likesAmount = "likes_amount"
   }
   
   mutating func update(likesAmount: Int, userLiked: Bool) {
      self.likesAmount = likesAmount
      self.userLiked = userLiked
   }
}

final class GetChallWinnersReportsApiWorker: BaseApiWorker<RequestWithId, [ChallengeWinnerReport]> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"

      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.ChallengeWinnersReports(
            id: String(request.id),
            headers: [
               Config.tokenHeaderKey: request.token,
               "X-CSRFToken": cookie.value
            ]
         ))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let winnersReports: [ChallengeWinnerReport] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: winnersReports)
         }
         .catch { _ in
            work.fail()
         }
   }
}
