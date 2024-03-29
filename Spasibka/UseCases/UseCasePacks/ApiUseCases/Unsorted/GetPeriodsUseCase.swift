//
//  GetPeriodsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.08.2022.
//

import Foundation
import StackNinja

struct GetPeriodsUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getPeriodsApiWorker: GetPeriodsApiWorker

   var work: Work<Void, [Period]> {
      Work<Void, [Period]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doNext(getPeriodsApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
