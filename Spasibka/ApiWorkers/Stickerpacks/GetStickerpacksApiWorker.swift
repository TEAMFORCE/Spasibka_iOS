//
//  GetStickerpacksApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 09.02.2023.
//

import Foundation

struct Stickerpack: Codable {
   let name: String
   let id: Int
   let organizationId: Int?
   
   enum CodingKeys: String, CodingKey {
      case name, id
      case organizationId = "organization_id"
   }
}

final class GetStickerpacksApiWorker: BaseApiWorker<String, [Stickerpack]> {
   override func doAsync(work: Wrk) {
      guard
         let token = work.input
      else {
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetStickerpacks(
            headers: [Config.tokenHeaderKey: token])
         )
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let stickerpacks: [Stickerpack] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: stickerpacks)
         }
         .catch { _ in
            work.fail()
         }
   }
}
