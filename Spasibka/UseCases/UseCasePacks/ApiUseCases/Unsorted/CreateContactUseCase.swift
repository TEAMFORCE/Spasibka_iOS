//
//  CreateContactUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 06.09.2022.
//
import StackNinja

struct CreateContactUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let createContactApiWorker: CreateContactApiWorker

   var work: Work<CreateContactRequest, Void> {
      Work<CreateContactRequest, Void>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let input = work.input else { return nil }
               let request = CreateContactRequest(token: $0,
                                                  contactId: input.contactId,
                                                  contactType: input.contactType,
                                                  profile: input.profile)
               return request
            }
            .doNext(createContactApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
