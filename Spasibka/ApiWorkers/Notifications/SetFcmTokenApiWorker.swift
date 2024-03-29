//
//  SetFcmTokenApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 09.11.2022.
//

import Foundation
import StackNinja

struct FcmRequest {
   let token: String
   let fcmToken: FcmToken
}
struct FcmToken: Codable {
   let token: String
   let device: String
}

final class SetFcmTokenApiWorker: BaseApiWorker<FcmRequest, Void> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"
      
      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         work.fail()
         return
      }

      apiEngine?
         .process(endpoint: SpasibkaEndpoints.SetFcmToken(headers: [
            Config.tokenHeaderKey: request.token,
            "X-CSRFToken": cookie.value
         ], body: request.fcmToken.dictionary ?? [:]))
         .done { result in
            work.success()
         }
         .catch { _ in
            work.fail()
         }
   }
}
