//
//  GetTagsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 12.09.2022.
//

import StackNinja

struct GetTagsUseCase: UseCaseProtocol {
   let getTagsApiWorker: GetTagsApiWorker

   var work: Work<String, [Tag]> {
      Work<String, [Tag]>() { work in

         getTagsApiWorker
            .doAsync(work.unsafeInput)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
