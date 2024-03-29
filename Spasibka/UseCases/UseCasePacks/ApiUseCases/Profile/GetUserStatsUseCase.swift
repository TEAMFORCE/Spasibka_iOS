//
//  GetUserStatsUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.12.2022.
//

import StackNinja

struct GetUserStatsUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getUserStatsWorker: GetUserStatsApiWorker

   var work: Work<Void, [UserStat]> {
      .init { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doNext(getUserStatsWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
