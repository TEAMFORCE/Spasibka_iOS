//
//  GetPeriodsFromDateUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 19.08.2022.
//

import StackNinja

struct GetPeriodsFromDateUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getPeriodsFromDateApiWorker: GetPeriodsFromDateApiWorker

   var work: Work<String, [Period]> {
      Work<String, [Period]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let date = work.input else { return nil }
               return RequestWithDate(token: $0, date: date)
            }
            .doNext(getPeriodsFromDateApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
