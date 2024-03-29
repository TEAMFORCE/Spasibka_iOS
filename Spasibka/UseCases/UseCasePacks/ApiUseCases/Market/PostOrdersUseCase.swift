//
//  PostOrdersUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 25.01.2023.
//

import Foundation
import StackNinja

struct PostOrdersUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let postOrdersApiWorker: PostOrdersApiWorker

   var work: Work<Int, Void> {
      Work<Int, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let id = work.input else { return nil }
               return ($0, id)
            }
            .doNext(postOrdersApiWorker)
            .onSuccess {
               work.success()
            }
            .onFail {
               work.fail()
            }
      }
   }
}
