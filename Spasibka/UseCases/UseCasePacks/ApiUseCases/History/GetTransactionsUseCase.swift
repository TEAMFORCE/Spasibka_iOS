//
//  GetTransactionsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 04.08.2022.
//

import Foundation
import StackNinja


struct GetTransactionsUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getTransactionsApiWorker: GetTransactionsApiWorker

   var work: Work<HistoryRequest, [Transaction]> {
      Work<HistoryRequest, [Transaction]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               log("No token")
               work.fail()
            }
            .doMap {
               guard
                  let input = work.input
               else { work.fail(); return nil }
               let request = HistoryRequest(token: $0,
                                            pagination: input.pagination,
                                            sentOnly: input.sentOnly,
                                            receivedOnly: input.receivedOnly)
               return request
            }
            .doNext(getTransactionsApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
