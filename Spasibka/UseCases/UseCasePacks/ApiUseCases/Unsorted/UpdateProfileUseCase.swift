//
//  UpdateProfileUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 30.08.2022.
//

import StackNinja
import UIKit

struct UpdateProfileUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let updateProfileApiWorker: UpdateProfileApiWorker
   
   var work: Work<UpdateProfileRequest, Void> {
      Work<UpdateProfileRequest, Void> { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard
                  let id = work.input?.id,
                  let info = work.input?.info
               else { return nil }
               return UpdateProfileRequest(token: $0,
                                           id: id,
                                           info: info)
            }
            .doNext(updateProfileApiWorker)
            .onSuccess {
               work.success()
            }
            .onFail {
               work.fail()
            }
      }
   }
}
