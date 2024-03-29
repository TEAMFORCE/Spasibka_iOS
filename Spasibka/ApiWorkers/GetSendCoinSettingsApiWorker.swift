//
//  GetSendCoinSettingsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 11.10.2022.
//

import StackNinja

struct SendCoinSettings: Codable {
   let tags: [Tag]?
   let isPublic: Bool
   let isAnonymousAvailable: Bool?
   
   enum CodingKeys: String, CodingKey {
      case tags
      case isPublic = "is_public"
      case isAnonymousAvailable = "is_anonymous_available"
   }
}

final class GetSendCoinSettingsApiWorker: BaseApiWorker<String, SendCoinSettings> {
   override func doAsync(work: Wrk) {
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.SendCoinSettings(headers: [
            Config.tokenHeaderKey: work.input.unwrap,
         ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let settings: SendCoinSettings = decoder.parse(data)
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
