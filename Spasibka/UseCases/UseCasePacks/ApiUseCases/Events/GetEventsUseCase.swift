//
//  GetEventsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.10.2022.
//

import Foundation
import StackNinja

struct GetEventsUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getEventsApiWorker: GetEventsApiWorker

   var work: Work<Pagination, [Feed]> {
      Work<Pagination, [Feed]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }
               return ($0, input)
            }
            .doNext(getEventsApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
