//
//  ChooseOrgApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import Foundation
import StackNinja

final class ChooseOrgApiWorker: BaseApiWorker<OrganizationAuth, AuthResult> {
   override func doAsync(work: Work<OrganizationAuth, AuthResult>) {
      guard
         let request = work.input
      else {
         return
      }

      apiEngine?
         .process(endpoint: SpasibkaEndpoints.ChooseOrganizationEndpoint(
            body: ["user_id": request.userId,
                   "organization_id": request.organizationId],
            headers: [:]))
         .done { result in
            guard
               let xCode = result.response?.headerValueFor("X-Code")
            else {
               work.fail()
               return
            }
            let account: Account?
            let xId: String?
            if (result.response?.headerValueFor("X-Telegram")) != nil {
               xId = result.response?.headerValueFor("X-Telegram") ?? ""
               account = .telegram
            } else {
               xId = result.response?.headerValueFor("X-Email") ?? ""
               account = .email
            }

            guard
               let xId = xId,
               let account = account
            else { return }
            
            work.success(result: AuthResult(xId: xId, xCode: xCode, account: account))
         }
         .catch { error in
            print(error)
            work.fail()
         }
   }
}

