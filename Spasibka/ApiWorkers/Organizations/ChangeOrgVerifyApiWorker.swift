//
//  ChangeOrganizationVerifyApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import Foundation
import StackNinja

final class ChangeOrgVerifyApiWorker: BaseApiWorker<VerifyRequest, VerifyResultBody> {
   override func doAsync(work: Work<VerifyRequest, VerifyResultBody>) {
      let cookieName = "csrftoken"

      guard
         let verifyRequest = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }

      apiEngine?
         .process(endpoint: SpasibkaEndpoints.ChangeOrganizationVerifyEndpoint(
            body: ["type": "authcode",
                   "code": verifyRequest.smsCode],
            headers: ["X-CSRFToken": cookie.value,
                      "tg_id": verifyRequest.xId.unwrap,
                      "X-Code": verifyRequest.xCode.unwrap,
                      "organization_id": verifyRequest.organizationId.unwrap]))
         .done { result in
            guard
               let data = result.data,
               let resultBody = VerifyResultBody(data)
            else {
               work.fail()
               return
            }

            work.success(result: resultBody)
         }
         .catch { error in
            print(error)
            work.fail()
         }
   }
}
