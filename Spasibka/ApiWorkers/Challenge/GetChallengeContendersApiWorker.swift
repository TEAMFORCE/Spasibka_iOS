//
//  GetChallengeContenders.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 06.10.2022.
//

import Foundation
import StackNinja

struct Contender: Codable {
   var userLiked: Bool?
   let participantId: Int
   let participantPhoto: String?
   let participantName: String?
   let participantSurname: String?
   let reportCreatedAt: String
   let reportText: String?
   let reportPhoto: String?
   let reportId: Int
   let commentsAmount: Int?
   var likesAmount: Int?
   let reportPhotos: [String]?
   
   mutating func update(likesAmount: Int, userLiked: Bool) {
      self.likesAmount = likesAmount
      self.userLiked = userLiked
   }
   
   enum CodingKeys: String, CodingKey {
      case userLiked = "user_liked"
      case participantId = "participant_id"
      case participantPhoto = "participant_photo"
      case participantName = "participant_name"
      case participantSurname = "participant_surname"
      case reportCreatedAt = "report_created_at"
      case reportText = "report_text"
      case reportPhoto = "report_photo"
      case reportId = "report_id"
      case commentsAmount = "comments_amount"
      case likesAmount = "likes_amount"
      case reportPhotos = "report_photos"
   }
   
}

final class GetChallengeContendersApiWorker: BaseApiWorker<RequestWithId, [Contender]> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"

      guard
         let input = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetChallengeContenders(
            id: String(input.id),
            headers: [
               Config.tokenHeaderKey: input.token,
               "X-CSRFToken": cookie.value
            ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let contenders: [Contender] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: contenders)
         }
         .catch { _ in
            work.fail()
         }
   }
}
