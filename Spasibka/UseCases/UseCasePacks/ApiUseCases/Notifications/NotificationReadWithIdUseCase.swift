//
//  NotificationReadWithId.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.11.2022.
//

import Foundation
import StackNinja

struct NotificationReadWithIdUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let notificationReadWithIdApiWorker: NotificationReadWithIdApiWorker
   
   var work: Work<Int, Void> {
      Work<Int, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let id = work.input else { return nil }
               return RequestWithId(token: $0, id: id)
            }
            .doNext(notificationReadWithIdApiWorker)
            .onSuccess {
               work.success($0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
