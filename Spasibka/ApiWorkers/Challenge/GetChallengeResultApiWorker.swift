//
//  GetChallengeResultApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 13.10.2022.
//

import Foundation
import StackNinja

struct ChallengeResult: Codable {
   let updatedAt: String
   let text: String?
   let photo: String?
   let status: String
   let received: Int?
   let photos: [String]?

   enum CodingKeys: String, CodingKey {
      case text, photo, status, received, photos
      case updatedAt = "updated_at"
   }
}

final class GetChallengeResultApiWorker: BaseApiWorker<RequestWithId, [ChallengeResult]> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"

      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      let endpoint = SpasibkaEndpoints.ChallengeResult(
         id: String(request.id),
         headers: [
            Config.tokenHeaderKey: request.token,
            "X-CSRFToken": cookie.value
         ]
      )
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let challengeResults: [ChallengeResult] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: challengeResults)
         }
         .catch { _ in
            work.fail()
         }
   }
}
