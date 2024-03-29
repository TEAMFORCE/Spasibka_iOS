//
//  LogoutUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.08.2022.
//

import Foundation
import StackNinja

struct LogoutUseCase: UseCaseProtocol {
   let loadToken: LoadTokenWorker
   let logoutApiModel: LogoutApiWorker

   var work: Work<Void, Void> {
      Work<Void, Void> { work in
         loadToken
            .doAsync()
            .onFail {
               work.fail()
            }
            .doMap {
               TokenRequest(token: $0)
            }
            .doNext(logoutApiModel)
            .onSuccess {
               work.success()
            }
            .onFail {
               work.fail()
            }
      }
   }
}
