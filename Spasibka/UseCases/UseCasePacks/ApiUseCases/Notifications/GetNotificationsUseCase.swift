//
//  GetNotificationsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 09.11.2022.
//

import StackNinja

struct GetNotificationsUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getNotificationsApiWorker: GetNotificationsApiWorker

   var work: Work<Pagination, [Notification]> {
      Work<Pagination, [Notification]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { work.fail(); return nil }
               let request = ($0, input)
               return request
            }
            .doNext(getNotificationsApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
