//
//  UpdateContactUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 30.08.2022.
//

import StackNinja

struct UpdateContactUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let updateContactApiWorker: UpdateContactApiWorker

   var work: Work<(Int, String), Void> {
      Work<(Int, String), Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }
               return UpdateContactRequest(token: $0, id: input.0, contactId: input.1)
            }
            .doNext(updateContactApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
