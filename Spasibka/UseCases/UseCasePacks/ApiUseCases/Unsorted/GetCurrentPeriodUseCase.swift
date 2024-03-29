//
//  GetCurrentPeriodUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 19.08.2022.
//

import Foundation
import StackNinja

struct GetCurrentPeriodUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getCurrentPeriodApiWorker: GetCurrentPeriodApiWorker

   var work: Work<Void, Period> {
      Work<Void, Period>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doNext(getCurrentPeriodApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
