//
//  GetTransactionByIdApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 10.08.2022.
//

import UIKit
import StackNinja

struct RequestWithId {
   let token: String
   let id: Int
   var vkAccessToken: String?
}

final class GetTransactionByIdApiWorker: BaseApiWorker<RequestWithId, Transaction> {
   override func doAsync(work: Work<RequestWithId, Transaction>) {
      let cookieName = "csrftoken"
      
      guard
         let transactionRequest = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      
      let endpoint = SpasibkaEndpoints.GetTransactionById(
         id: String(transactionRequest.id),
         headers: [Config.tokenHeaderKey: transactionRequest.token,
                   "X-CSRFToken": cookie.value]
      )
      
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let transaction: Transaction = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: transaction)
         }
         .catch { _ in
            work.fail()
         }
   }
}
