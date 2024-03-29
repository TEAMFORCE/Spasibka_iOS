//
//  GetEventsChallApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.10.2022.
//

import StackNinja

final class GetEventsChallApiWorker: BaseApiWorker<(String, Pagination), [Feed]> {
   override func doAsync(work: Wrk) {
      guard let request = work.input
      else {
         work.fail()
         return
      }

      let endpoint = SpasibkaEndpoints.EventsChallenges(
         offset: request.1.offset,
         limit: request.1.limit,
         headers: [ Config.tokenHeaderKey: request.0 ]
      )
      
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let feeds: [Feed] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: feeds)
         }
         .catch { _ in
            work.fail()
         }
   }
}
