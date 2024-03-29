//
//  LoadBalanceUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.08.2022.
//

import Foundation
import StackNinja

struct LoadBalanceUseCase: UseCaseProtocol {
   let loadToken: LoadTokenWorker
   let balanceApiModel: GetBalanceApiWorker

   var work: Work<Void, Balance> { .init { work in
      //
      loadToken
         .doAsync()
         .onFail {
            work.fail()
         }
         .doNext(balanceApiModel)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   } }
}
