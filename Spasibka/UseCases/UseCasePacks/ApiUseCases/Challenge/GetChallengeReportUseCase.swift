//
//  GetChallengeReportUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.10.2022.
//

import StackNinja

struct GetChallengeReportUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getChallengeReportApiWorker: GetChallengeReportApiWorker

   var work: Work<Int, ChallengeReport> {
      Work<Int, ChallengeReport>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let id = work.input else { return nil }
               return RequestWithId(token: $0, id: id)
            }
            .doNext(getChallengeReportApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
