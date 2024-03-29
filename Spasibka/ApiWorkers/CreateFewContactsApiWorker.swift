//
//  CreateFewContactsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 07.09.2022.
//

import Foundation
import StackNinja

struct CreateFewContactsRequest: Codable {
   let token: String
   let info: [FewContacts]
}

struct FewContacts: Codable {
   let id: Int?
   let contactType: String
   let contactId: String

   enum CodingKeys: String, CodingKey {
      case id
      case contactType = "contact_type"
      case contactId = "contact_id"
   }
}

final class CreateFewContactsApiWorker: BaseApiWorker<CreateFewContactsRequest, Void> {
   override func doAsync(work: Work<CreateFewContactsRequest, Void>) {
      let cookieName = "csrftoken"

      guard
         let CreateFewContactsRequest = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      
      do {
         let jsonData = try JSONEncoder().encode(CreateFewContactsRequest.info)
         let endpoint = SpasibkaEndpoints.CreateFewContacts(
            jsonData: jsonData,
            headers: [Config.tokenHeaderKey: CreateFewContactsRequest.token,
                      "X-CSRFToken": cookie.value,
                      "Content-Type": "application/json"]
         )
         print("endpoint is \(endpoint)")
         apiEngine?
            .process(endpoint: endpoint)
            .done { result in
               let str = String(decoding: result.data!, as: UTF8.self)
               print(str)
               print("response status \(String(describing: result.response))")
               work.success()
            }
            .catch { _ in
               work.fail()
            }
      } catch {
         print(error)
      }
   }
}
