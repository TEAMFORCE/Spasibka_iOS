//
//  GetChallengeWinnersApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 07.10.2022.
//

import Foundation
import StackNinja
struct ChallengeWinner: Codable {
   let nickname: String?
   let totalReceived: Int?
   let participantId: Int?
   let participantPhoto: String?
   let participantName: String?
   let participantSurname: String?
   let awardedAt: String?
   let userLiked: Bool?
   let commentsAmount: Int?
   let likesAmount: Int?
   
   enum CodingKeys: String, CodingKey {
      case nickname
      case totalReceived = "total_received"
      case participantId = "participant_id"
      case participantPhoto = "participant_photo"
      case participantName = "participant_name"
      case participantSurname = "participant_surname"
      case awardedAt = "awarded_at"
      case userLiked = "user_liked"
      case commentsAmount = "comments_amount"
      case likesAmount = "likes_amount"
   }
}

final class GetChallengeWinnersApiWorker: BaseApiWorker<RequestWithId, [ChallengeWinner]> {
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
         .process(endpoint: SpasibkaEndpoints.ChallengeWinners(
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
               let winners: [ChallengeWinner] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: winners)
         }
         .catch { _ in
            work.fail()
         }
   }
}
