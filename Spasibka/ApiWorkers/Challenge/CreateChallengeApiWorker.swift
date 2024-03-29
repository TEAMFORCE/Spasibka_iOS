//
//  CreateChallengeApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 06.10.2022.
//

import Foundation
import StackNinja
import UIKit

struct ChallengeRequestBody: Encodable {
   let name: String
   let description: String?
   let startAt: String?
   let endAt: String?
   let startBalance: Int
   let photo: [UIImage]?
   let parameterId: Int?
   let parameterValue: Int?
   let challengeType: String?
   let showParticipants: String?
   let severalReports: String?
   let accountId: Int?

   enum CodingKeys: String, CodingKey {
      case name, description // , photo
      case startAt = "start_at"
      case endAt = "end_at"
      case startBalance = "start_balance"
      case parameterId = "parameter_id"
      case parameterValue = "parameter_value"
      case challengeType = "challenge_type"
      case showParticipants = "show_contenders"
      case severalReports = "multiple_reports"
      case accountId = "account_id"
   }

   init(name: String,
        description: String? = nil,
        startAt: String? = nil,
        endAt: String? = nil,
        startBalance: Int,
        photo: [UIImage]? = nil,
        parameterId: Int? = nil,
        parameterValue: Int? = nil,
        challengeType: String? = nil,
        showParticipants: String? = nil,
        severalReports: String? = nil,
        accountId: Int? = nil
   )
   {
      self.name = name
      self.description = description
      self.startAt = startAt
      self.endAt = endAt
      self.startBalance = startBalance
      self.photo = photo
      self.parameterId = parameterId
      self.parameterValue = parameterValue
      self.challengeType = challengeType
      self.showParticipants = showParticipants
      self.severalReports = severalReports
      self.accountId = accountId
   }
}

struct CreateChallengeRequest {
   let token: String
   let body: ChallengeRequestBody
}

final class CreateChallengeApiWorker: BaseApiWorker<CreateChallengeRequest, Void> {
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

      let endpoint = SpasibkaEndpoints.CreateChallenge(
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
               print("error coin sending: \(error)")
               work.fail()
            }
      } else {
         apiEngine?
            .process(endpoint: endpoint)
            .done { _ in
               work.success()
            }
            .catch { _ in
               work.fail()
            }
      }
   }
}
