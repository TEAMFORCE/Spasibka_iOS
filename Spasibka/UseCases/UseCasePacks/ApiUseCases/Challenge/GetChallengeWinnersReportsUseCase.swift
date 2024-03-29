//
//  GetChallengeWinnersReportsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.10.2022.
//

import StackNinja

struct GetChallWinnersReportsUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getChallWinnersReportsApiWorker: GetChallWinnersReportsApiWorker

   var work: Work<Int, [ChallengeWinnerReport]> {
      Work<Int, [ChallengeWinnerReport]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let id = work.input else { return nil }
               return RequestWithId(token: $0, id: id)
            }
            .doNext(getChallWinnersReportsApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
