//
//  GetTagsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 12.09.2022.
//

import StackNinja

struct Reason: Codable {
   let id: Int
   let data: String?
}

struct Tag: Codable, Hashable {
   let id: Int
   let name: String?
   let reasons: [Reason]?

   func hash(into hasher: inout Hasher) {
      hasher.combine(id)
   }
   
   static func == (lhs: Tag, rhs: Tag) -> Bool {
      lhs.id == rhs.id
   }
}

final class GetTagsApiWorker: BaseApiWorker<String, [Tag]> {
   override func doAsync(work: Wrk) {
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.Tags(headers: [
            Config.tokenHeaderKey: work.input.unwrap,
         ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let tags: [Tag] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: tags)
         }
         .catch { _ in
            work.fail()
         }
   }
}

