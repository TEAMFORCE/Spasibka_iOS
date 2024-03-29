//
//  CreateFewContactsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 07.09.2022.
//

import StackNinja

struct CreateFewContactsUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let createFewContactsApiWorker: CreateFewContactsApiWorker

   var work: Work<CreateFewContactsRequest, Void> {
      Work<CreateFewContactsRequest, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }
               let request = CreateFewContactsRequest(token: $0,
                                                      info: input.info)
               return request
            }
            .doNext(createFewContactsApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
