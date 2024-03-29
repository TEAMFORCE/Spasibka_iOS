//
//  GetPeriodsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.08.2022.
//

import Foundation
import StackNinja

struct Period: Codable {
   let id: Int
   let startDate: String
   let endDate: String
   let name: String
   
   enum CodingKeys: String, CodingKey {
      case id
      case startDate = "start_date"
      case endDate = "end_date"
      case name
   }
}

final class GetPeriodsApiWorker: BaseApiWorker<String, [Period]> {
   override func doAsync(work: Wrk) {
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.Periods(headers: [
            Config.tokenHeaderKey: work.input.unwrap,
         ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let periods: [Period] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: periods)
         }
         .catch { _ in
            work.fail()
         }
   }
}
