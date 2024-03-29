//
//  CheckChallengeReportApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 09.10.2022.
//

import Foundation
import StackNinja

struct CheckReportRequestBody: Codable {
   let id: Int
   let state: State
   let text: String?
   
   enum State: String, Codable {
      case W = "W"
      case D = "D"
   }
   
   enum CodingKeys: String, CodingKey {
      case id
      case state
      case text
   }
}

struct CheckReportRequest {
   let token: String
   let body: CheckReportRequestBody
}

final class CheckChallengeReportApiWorker: BaseApiWorker<CheckReportRequest, Void> {
   override func doAsync(work: Work<CheckReportRequest, Void>) {
      let cookieName = "csrftoken"
      
      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      
      let jsonData = try? JSONEncoder().encode(request.body)
      let endpoint = SpasibkaEndpoints.CheckChallengeReport(
         id: String(request.body.id),
         headers: [Config.tokenHeaderKey: request.token,
                   "X-CSRFToken": cookie.value,
                   "Content-Type": "application/json"],
         jsonData: jsonData
      )
      
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            work.success()
         }
         .catch { _ in
            work.fail()
         }
   }
}
