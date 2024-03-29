//
//  GetChallengeWinnersUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 07.10.2022.
//

import StackNinja

struct GetChallengeWinnersUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getChallengeWinnersApiWorker: GetChallengeWinnersApiWorker

   var work: Work<Int, [ChallengeWinner]> {
      Work<Int, [ChallengeWinner]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let id = work.input else { return nil }
               return RequestWithId(token: $0, id: id)
            }
            .doNext(getChallengeWinnersApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
