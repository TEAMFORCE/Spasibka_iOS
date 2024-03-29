//
//  CreateCommentUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 26.09.2022.
//

import StackNinja

struct CreateCommentUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let createCommentApiWorker: CreateCommentApiWorker

   var work: Work<CreateCommentRequest, Void> {
      Work<CreateCommentRequest, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }
               let request = CreateCommentRequest(token: $0,
                                                 body: input.body)
               return request
            }
            .doNext(createCommentApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
