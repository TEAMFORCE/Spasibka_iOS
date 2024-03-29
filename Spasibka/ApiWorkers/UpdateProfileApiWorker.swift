//
//  UpdateProfileApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 29.08.2022.
//

import Foundation
import StackNinja

struct UpdateProfileRequest {
   let token: String
   let id: Int
   let info: [String : Any]
}

final class UpdateProfileApiWorker: BaseApiWorker<UpdateProfileRequest, Void> {
   override func doAsync(work: Work<UpdateProfileRequest, Void>) {
      let cookieName = "csrftoken"
      
      guard
         let updateProfileRequest = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      let endpoint = SpasibkaEndpoints.UpdateProfile(
         id: String(updateProfileRequest.id),
         headers: [Config.tokenHeaderKey: updateProfileRequest.token,
                   "X-CSRFToken": cookie.value],
         body: updateProfileRequest.info
      )
      print("endpoint is \(endpoint)")
      apiEngine?
         .processPUT(endpoint: endpoint)
         .done { result in
            work.success()
         }
         .catch { _ in
            work.fail()
         }
   }
}
