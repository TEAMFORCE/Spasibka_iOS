//
//  CreateChallengeReportUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 07.10.2022.
//

import StackNinja

struct CreateChallengeReportUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let createChallengeReportApiWorker: CreateChallengeReportApiWorker

   var work: Work<ChallengeReportBody, Void> {
      Work<ChallengeReportBody, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }
               return CreateChallengeReportRequest(token: $0, body: input)
            }
            .doNext(createChallengeReportApiWorker)
            .onSuccess {
               work.success()
            }
            .onFail {
               work.fail()
            }
      }
   }
}
