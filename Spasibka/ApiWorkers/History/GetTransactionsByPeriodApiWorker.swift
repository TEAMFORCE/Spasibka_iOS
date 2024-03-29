//
//  GetTransactionsByPeriodApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 16.08.2022.
//

import UIKit
import StackNinja

final class GetTransactionsByPeriodApiWorker: BaseApiWorker<RequestWithId, [Transaction]> {
   override func doAsync(work: Work<RequestWithId, [Transaction]>) {
      
      guard
         let transactionRequest = work.input
      else {
         work.fail()
         return
      }
      
      let endpoint = SpasibkaEndpoints.GetTransactionByPeriod(
         id: String(transactionRequest.id),
         headers: [Config.tokenHeaderKey: transactionRequest.token,]
      )
      
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let transactions: [Transaction] = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: transactions)
         }
         .catch { _ in
            work.fail()
         }
   }
}
