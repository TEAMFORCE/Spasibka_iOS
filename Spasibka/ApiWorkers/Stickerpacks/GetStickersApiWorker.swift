//
//  GetStickersApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 09.02.2023.
//

import Foundation

struct Sticker: Codable {
   let id: Int
   let stickerpackId: Int
   let image: String
   
   enum CodingKeys: String, CodingKey {
      case id, image
      case stickerpackId = "stickerpackid"
   }
}

final class GetStickersApiWorker: BaseApiWorker<String, [Sticker]> {
   override func doAsync(work: Wrk) {
      guard
         let token = work.input
      else {
         return
      }
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetStickers(
            headers: [Config.tokenHeaderKey: token])
         )
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let stickers: [Sticker] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: stickers)
         }
         .catch { _ in
            work.fail()
         }
   }
}
