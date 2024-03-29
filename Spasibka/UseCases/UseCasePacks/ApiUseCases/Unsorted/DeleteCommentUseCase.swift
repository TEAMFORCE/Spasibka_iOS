//
//  DeleteCommentUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 26.09.2022.
//

import StackNinja

struct DeleteCommentUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let deleteCommentApiWorker: DeleteCommentApiWorker

   var work: Work<RequestWithId, Void> {
      Work<RequestWithId, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }

               let request = RequestWithId(token: $0, id: input.id)
               return request
            }
            .doNext(deleteCommentApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
