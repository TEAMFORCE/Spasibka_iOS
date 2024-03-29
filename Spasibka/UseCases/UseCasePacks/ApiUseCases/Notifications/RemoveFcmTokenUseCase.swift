//
//  RemoveFcmTokenUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 09.11.2022.
//

import StackNinja

struct RemoveFcmTokenUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let removeFcmTokenApiWorker: RemoveFcmTokenApiWorker

   var work: Work<RemoveFcmToken, Void> {
      Work<RemoveFcmToken, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }
               let request = RemoveFcmRequest(token: $0, removeFcmToken: input)
               return request
            }
            .doNext(removeFcmTokenApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
