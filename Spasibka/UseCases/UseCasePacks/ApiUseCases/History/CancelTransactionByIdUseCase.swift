//
//  CancelTransactionByIdUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 16.08.2022.
//

import Foundation
import StackNinja

struct CancelTransactionByIdUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let cancelTransactionByIdApiWorker: CancelTransactionByIdApiWorker
   
   var work: Work<Int, Void> {
      Work<Int, Void> { work in
         safeStringStorage
            .doAsync(Config.tokenKey) // TODO: - Token key input
            .onFail {
               work.fail() // TODO: - Error
            }
            .doMap {
               guard let id = work.input else { return nil }
               return RequestWithId(token: $0, id: id)
            }
            .doNext(cancelTransactionByIdApiWorker)
            .onSuccess {
               work.success()
            }
            .onFail {
               work.fail() // TODO: - Error
            }
      }
   }
}
