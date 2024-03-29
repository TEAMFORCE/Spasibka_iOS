//
//  CloseChallengeUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 08.12.2022.
//

import StackNinja

struct CloseChallengeUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let closeChallengeApiWorker: CloseChallengeApiWorker

   var work: Work<Int, Void> {
      Work<Int, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               log("No token")
               work.fail()
            }
            .doMap {
               guard let id = work.input else { return nil }
               return RequestWithId(token: $0, id: id)
            }
            .doNext(closeChallengeApiWorker)
            .onSuccess {
               work.success()
            }
            .onFail {
               work.fail()
            }
      }
   }
}
