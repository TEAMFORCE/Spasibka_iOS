//
//  GetLikesUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 22.11.2022.
//

import StackNinja

struct GetLikesUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getLikesApiWorker: GetLikesApiWorker

   var work: Work<LikesRequestBody, [ReactItem]> {
      Work<LikesRequestBody, [ReactItem]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }
               let request = LikesRequest(token: $0,
                                                    body: input)
               return request
            }
            .doNext(getLikesApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
