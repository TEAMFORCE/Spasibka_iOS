//
//  GetTransactionByIdUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 10.08.2022.
//

import Foundation
import StackNinja

struct GetTransactionByIdUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getTransactionByIdApiModel: GetTransactionByIdApiWorker
   
   var work: Work<Int, Transaction> {
      Work<Int, Transaction>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let id = work.input else { return nil }
               return RequestWithId(token: $0, id: id)
            }
            .doNext(getTransactionByIdApiModel)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
