//
//  ChangeOrganizationApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import StackNinja
import Foundation

final class ChangeOrganizationApiWorker: BaseApiWorker<RequestWithId, AuthResult> {
   
   struct ChangeOrgBody: Codable {
      let organizationId: Int
      let accessToken: String?
      enum CodingKeys: String, CodingKey {
         case organizationId = "organization_id"
         case accessToken = "access_token"
      }
   }
   
   override func doAsync(work: Work<RequestWithId, AuthResult>) {
      let cookieName = "csrftoken"
      
      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      let body = ChangeOrgBody(organizationId: request.id, accessToken: request.vkAccessToken)
      let jsonData = try? JSONEncoder().encode(body)
      let endpoint = SpasibkaEndpoints.ChangeOrganization(
         headers: [Config.tokenHeaderKey: request.token,
                   "X-CSRFToken": cookie.value,
                   "Content-Type": "application/json"],
         jsonData: jsonData
      )

      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            guard
               let xCode = result.response?.headerValueFor("X-Code")
            else {
               work.fail()
               return
            }
            let account: Account?
            let organizationId: String?
            let xId: String?
            if (result.response?.headerValueFor("tg_id")) != nil {
               xId = result.response?.headerValueFor("tg_id") ?? ""
               account = .telegram
            } else {
               xId = result.response?.headerValueFor("X-Email") ?? ""
               account = .email
            }
            
            if let orgId = result.response?.headerValueFor("organization_id") {
               organizationId = orgId
            } else {
               organizationId = ""
            }
            
            guard
               let xId = xId,
               let account = account,
               let organizationId = organizationId
            else { return }
            work.success(result: AuthResult(
               xId: xId,
               xCode: xCode,
               account: account,
               organizationId: organizationId
            ))
         }
         .catch { error in
            print(error)
            work.fail()
         }
   }
}


