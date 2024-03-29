//
//  CloseChallengeApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 08.12.2022.
//

import Foundation

final class CloseChallengeApiWorker: BaseApiWorker<RequestWithId, Void> {
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
         .process(endpoint: SpasibkaEndpoints.CloseChallenge(
            id: String(request.id),
            headers: [
               Config.tokenHeaderKey: request.token,
               "X-CSRFToken": cookie.value
            ]
         ))
         .done { result in
            work.success()
         }
         .catch { _ in
            work.fail()
         }
   }
}
