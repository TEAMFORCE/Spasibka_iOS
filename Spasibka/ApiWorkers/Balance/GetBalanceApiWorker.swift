//
//  GetBalanceApiModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.07.2022.
//

import Foundation
import StackNinja

final class GetBalanceApiWorker: BaseApiWorker<String, Balance> {
   override func doAsync(work: Wrk) {
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.BalanceEndpoint(headers: [
            Config.tokenHeaderKey: work.input.unwrap,
         ]))
         .done { result in
            guard
               let data = result.data,
               let balance = Balance(data)
            else {
               work.fail()
               return
            }

            work.success(result: balance)
         }
         .catch { _ in
            work.fail()
         }
   }
}
