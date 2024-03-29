//
//  GetChallengeByIdApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 06.10.2022.
//

import Foundation
import StackNinja

final class GetChallengeByIdApiWorker: BaseApiWorker<RequestWithId, Challenge> {
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
         .process(endpoint: SpasibkaEndpoints.GetChallengeById(
            id: String(input.id),
            headers: [
               Config.tokenHeaderKey: input.token,
               "X-CSRFToken": cookie.value
            ]))
         .done { result in
            guard
               let data = result.data,
               let challenge = Challenge(data)
            else {
               work.fail()
               return
            }
            work.success(result: challenge)
         }
         .catch { error in
            work.fail(error)
            work.fail()
         }
   }
}
