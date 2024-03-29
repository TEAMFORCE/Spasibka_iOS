//
//  AddToCartApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 24.01.2023.
//

import Foundation
import StackNinja

struct AddToCartRequest: Codable {
   let offerId: Int
   let quantity: Int
   let status: String?
   
   enum CodingKeys: String, CodingKey {
      case offerId = "offer_id"
      case quantity, status
   }
}

struct AddToCartResponse: Codable {
   let id: Int
   let offerId: Int
   let marketplaceId: Int
   let orderStatus: Int?
   let quantity: Int?
   let price: Int?
   let amount: Int?
   
   enum CodingKeys: String, CodingKey {
      case id, quantity, price, amount
      case offerId = "offer_id"
      case marketplaceId = "marketplace_id"
      case orderStatus = "order_status"
   }
}

final class AddToCartApiWorker: BaseApiWorker<(String, AddToCartRequest, Int), AddToCartResponse> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"
      
      guard
         let token = work.input?.0,
         let body = work.input?.1,
         let marketId = work.input?.2,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         return
      }
      let jsonData = try? JSONEncoder().encode(body)
      let endpoint = SpasibkaEndpoints.AddToCart(
         marketId: marketId,
         headers: [Config.tokenHeaderKey: token,
                   "X-CSRFToken": cookie.value,
                   "Content-Type": "application/json"],
         jsonData: jsonData
      )
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let response: AddToCartResponse = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: response)
         }
         .catch { _ in
            work.fail()
         }
   }
}
