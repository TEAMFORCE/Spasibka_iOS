//
//  GetEventsChallUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.10.2022.
//

import StackNinja

struct GetEventsChallUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getEventsChallApiWorker: GetEventsChallApiWorker

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
            .doNext(getEventsChallApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
