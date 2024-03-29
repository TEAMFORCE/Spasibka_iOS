//
//  GetCartItemsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.01.2023.
//

import Foundation
import StackNinja

struct CartItem: Codable, SpasibkaConvertedImagesProtocol {
   let id: Int
   let quantity: Int?
   let price: Int?
   let offerId: Int
   let total: Int?
   let name: String?
   let actualTo: String?
   let rest: Int?
   let images: [BenefitImage]?
   let isChosen: Bool?
   let unavailable: Bool?
   let createdAt: String?
   let orderStatus: Int?
   let description: String?

   init(id: Int,
        quantity: Int?,
        price: Int?,
        offerId: Int,
        total: Int?,
        name: String?,
        actualTo: String?,
        rest: Int?,
        images: [BenefitImage]?,
        isChosen: Bool?,
        unavailable: Bool?,
        createdAt: String?,
        orderStatus: Int?,
        description: String?
   )
   {
      self.id = id
      self.quantity = quantity
      self.price = price
      self.offerId = offerId
      self.total = total
      self.name = name
      self.actualTo = actualTo
      self.rest = rest
      self.images = images
      self.isChosen = isChosen
      self.unavailable = unavailable
      self.createdAt = createdAt
      self.orderStatus = orderStatus
      self.description = description
   }

   enum CodingKeys: String, CodingKey {
      case id, quantity, price, total, name, images, rest, unavailable, description
      case offerId = "offer_id"
      case actualTo = "actual_to"
      case isChosen = "is_chosen"
      case createdAt = "created_at"
      case orderStatus = "current_status"
   }
}

final class GetCartItemsApiWorker: BaseApiWorker<(String, Int), [CartItem]> {
   override func doAsync(work: Wrk) {
      guard
         let request = work.input
      else {
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetCartItems(
            id: request.1,
            headers: [Config.tokenHeaderKey: request.0])
         )
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let items: [CartItem] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: items)
         }
         .catch { _ in
            work.fail()
         }
   }
}
