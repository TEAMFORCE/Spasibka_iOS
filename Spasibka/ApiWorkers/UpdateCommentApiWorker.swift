//
//  UpdateCommentApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 26.09.2022.
//

import Foundation
import StackNinja

struct UpdateCommentRequest {
   let token: String
   let id: Int
   let body: UpdateCommentBody?
}

struct UpdateCommentBody: Codable {
   let text: String?
   //let picture: UIImage?
}

final class UpdateCommentApiWorker: BaseApiWorker<UpdateCommentRequest, Void> {
   override func doAsync(work: Work<UpdateCommentRequest, Void>) {
      let cookieName = "csrftoken"
      
      guard
         let request = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      let endpoint = SpasibkaEndpoints.UpdateComment(
         id: String(request.id),
         headers: [Config.tokenHeaderKey: request.token,
                   "X-CSRFToken": cookie.value],
         body: request.body.dictionary ?? [:]
      )
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
