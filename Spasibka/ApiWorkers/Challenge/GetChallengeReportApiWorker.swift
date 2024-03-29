//
//  GetChallengeReportApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.10.2022.
//

import Foundation
import StackNinja

struct ChallengeReport: Codable {
   struct Challenge: Codable {
      let id: Int
      let name: String?
   }
   let challenge: Challenge
   let user: User
   let text: String?
   let createdAt: String?
   let photo: String?
   let photos: [String]?
   let userLiked: Bool?
   let myReport: Bool?
   let likesAmount: Int?
   let commentsAmount: Int?
   
   enum CodingKeys: String, CodingKey {
      case challenge, user, text, photo, photos
      case createdAt = "created_at"
      case userLiked = "user_liked"
      case myReport = "my_report"
      case likesAmount = "likes_amount"
      case commentsAmount = "comments_amount"
   }
}

final class GetChallengeReportApiWorker: BaseApiWorker<RequestWithId, ChallengeReport> {
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
         .process(endpoint: SpasibkaEndpoints.ChallengeReport(
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
               let report: ChallengeReport = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: report)
         }
         .catch { _ in
            work.fail()
         }
   }
}
