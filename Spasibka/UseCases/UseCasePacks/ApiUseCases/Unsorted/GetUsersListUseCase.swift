//
//  GetUsersListUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 11.08.2022.
//

import Foundation
import StackNinja

struct GetUsersListUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getUsersListApiWorker: GetUsersListApiWorker
   
   var work: Work<Int, [FoundUser]> {
      Work<Int, [FoundUser]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let limit = work.input else { return nil }
               let request = ($0, limit)
               return request
            }
            .doNext(getUsersListApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
