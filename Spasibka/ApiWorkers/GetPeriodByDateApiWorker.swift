//
//  GetPeriodByDateApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 19.08.2022.
//

import Foundation
import StackNinja

struct RequestWithDate {
   let token: String
   let date: String
}

final class GetPeriodByDateApiWorker: BaseApiWorker<RequestWithDate, Period> {
   override func doAsync(work: Wrk) {
      let cookieName = "csrftoken"
      
      guard
         let input = work.input,
         let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
      else {
         print("No csrf cookie")
         work.fail()
         return
      }
      
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetPeriodByDate(
            body: ["date": input.date],
            headers: [Config.tokenHeaderKey: input.token,
                      "X-CSRFToken": cookie.value
                     ]))
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let period: Period = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: period)
         }
         .catch { _ in
            work.fail()
         }
   }
}
