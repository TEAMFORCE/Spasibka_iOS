//
//  GetOrganizationBrand.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 22.12.2022.
//

import Foundation
import StackNinja

struct OrganizationSettings: Codable {
   let name: String?
   let telegramGroup: [String]?
   let hex: String?
   let photo: String?
   let licenseEnd: String?
   
   enum CodingKeys: String, CodingKey {
      case name, hex, photo
      case telegramGroup = "telegram_group"
      case licenseEnd = "license_end"
   }
}

final class GetOrgSettingsApiWorker: BaseApiWorker<String, OrganizationSettings> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"

      guard
         let token = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetOrganizationSettings(
            headers: [
               Config.tokenHeaderKey: token,
            "X-CSRFToken": cookie.value
         ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let settings: OrganizationSettings = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: settings)
         }
         .catch { _ in
            work.fail()
         }
   }
}
