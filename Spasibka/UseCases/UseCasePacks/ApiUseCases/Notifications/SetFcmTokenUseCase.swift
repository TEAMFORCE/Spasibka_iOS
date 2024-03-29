//
//  SetFcmTokenUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 09.11.2022.
//

import StackNinja

struct SetFcmTokenUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let setFcmTokenApiWorker: SetFcmTokenApiWorker

   var work: Work<FcmToken, Void> {
      Work<FcmToken, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }
               let request = FcmRequest(token: $0, fcmToken: input)
               return request
            }
            .doNext(setFcmTokenApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
