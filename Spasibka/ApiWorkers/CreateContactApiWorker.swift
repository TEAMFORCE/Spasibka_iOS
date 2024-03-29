//
//  CreateContactApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 29.08.2022.
//

import Foundation
import StackNinja

struct CreateContactRequest {
   let token: String
   let contactId: String
   let contactType: String
   let profile: Int
}

final class CreateContactApiWorker: BaseApiWorker<CreateContactRequest, Void> {
   override func doAsync(work: Work<CreateContactRequest, Void>) {
      let cookieName = "csrftoken"
      
      guard
         let CreateContactRequest = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      let endpoint = SpasibkaEndpoints.CreateContact(
         body: ["contact_id": CreateContactRequest.contactId,
                "contact_type": CreateContactRequest.contactType,
                "profile": CreateContactRequest.profile],
         headers: [Config.tokenHeaderKey: CreateContactRequest.token,
                  "X-CSRFToken": cookie.value]
      )
      print("endpoint is \(endpoint)")
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
//            let str = String(decoding: result.data!, as: UTF8.self)
//            print(str)
//            print("response status \(result.response)")
            work.success()
         }
         .catch { _ in
            work.fail()
         }
   }
}
