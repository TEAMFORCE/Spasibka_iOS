//
//  GetNotificationsAmountUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.11.2022.
//

import StackNinja

struct GetNotificationsAmountUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getNotificationsAmountApiWorker: GetNotificationsAmountApiWorker

   var work: Work<Void, Int> {
      Work<Void, Int>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               $0
            }
            .doNext(getNotificationsAmountApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
