//
//  GetLastPeriodRateUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.12.2022.
//

import StackNinja

struct LastPeriodRate: Decodable {
   let rate: Int
}

struct GetLastPeriodRateUseCase: UseCaseProtocol {
   let apiEngine: ApiEngineProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<Void, LastPeriodRate> { .init { work in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onSuccess { token in
            self.apiEngine
               .process(endpoint: SpasibkaEndpoints.GetLastPeriodRate(headers: [
                  Config.tokenHeaderKey: token,
               ]))
               .done { result in
                  let decoder = DataToDecodableParser()

                  guard
                     let data = result.data,
                     let rate: LastPeriodRate = decoder.parse(data)
                  else {
                     work.fail()
                     return
                  }

                  work.success(result: rate)
               }
               .catch { _ in
                  print("GetLastPeriodRate Failure!")
                  work.fail()
               }
         }
         .onFail {
            work.fail()
         }
   } }
}
