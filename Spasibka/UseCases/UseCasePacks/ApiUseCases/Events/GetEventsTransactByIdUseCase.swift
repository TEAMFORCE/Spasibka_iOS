//
//  GetEventsTransactByIdUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.10.2022.
//

import StackNinja

struct GetEventsTransactByIdUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getEventsTransactByIdApiModel: GetEventsTransactByIdApiWorker
   
   var work: Work<Int, EventTransaction> {
      Work<Int, EventTransaction>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let id = work.input else { return nil }
               return RequestWithId(token: $0, id: id)
            }
            .doNext(getEventsTransactByIdApiModel)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
