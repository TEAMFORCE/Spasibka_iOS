//
//  GetProfileByIdUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 13.09.2022.
//

import StackNinja

struct GetProfileByIdUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getProfileByIdApiWorker: GetProfileByIdApiWorker

   var work: Work<Int, UserData> {
      Work<Int, UserData>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }
               let request = RequestWithId(token: $0, id: input)
               return request
            }
            .doNext(getProfileByIdApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
      
      
   }
}
