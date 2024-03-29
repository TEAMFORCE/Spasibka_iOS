//
//  CreateChallengeReportApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 07.10.2022.
//

import Foundation
import StackNinja
import UIKit

struct ChallengeReportBody: Encodable {
   let challengeId: Int
   let text: String?
   let photo: [UIImage]?
   
   enum CodingKeys: String, CodingKey {
      case challengeId = "challenge"
      case text
      //case photo
   }
   init(challengeId: Int,
        text: String? = nil,
        photo: [UIImage]? = nil) {
      self.challengeId = challengeId
      self.text = text
      self.photo = photo
   }
}

struct CreateChallengeReportRequest {
   let token: String
   let body: ChallengeReportBody
}

final class CreateChallengeReportApiWorker: BaseApiWorker<CreateChallengeReportRequest, Void> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"

      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }
      let body = request.body.dictionary ?? [:]

      let endpoint = SpasibkaEndpoints.CreateChallengeReport(
         headers: [
            Config.tokenHeaderKey: request.token,
            "X-CSRFToken": cookie.value
         ],
         body: body
      )
      if let photo = request.body.photo {
         let names = [String](repeating: "photo", count: photo.count)
         apiEngine?
            .processWithImages(endpoint: endpoint,
                               images: photo,
                               names: names)
            .done { _ in
               work.success()
            }
            .catch { error in
               work.fail()
            }
      } else {
         // TODO: - check header urlencoded
         let names: [String] = []
         apiEngine?
            .processWithImages(endpoint: endpoint,
                               images: [],
                               names: names)
            .done { _ in
               work.success()
            }
            .catch { error in
               work.fail()
            }
      }
   }
}
