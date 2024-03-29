//
//  CreateChallengeGetUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 06.12.2022.
//

import StackNinja

struct CreateChallengeGetUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let createChallengeGetApiWorker: GetCreateChallengeSettingsApiWorker

   var work: Work<Void, CreateChallengeSettings> {
      Work<Void, CreateChallengeSettings>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doNext(createChallengeGetApiWorker)
            .onSuccess {
               work.success($0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
