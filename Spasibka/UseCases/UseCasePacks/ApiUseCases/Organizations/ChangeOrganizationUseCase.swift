//
//  ChangeOrganizationUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import Foundation
import StackNinja

struct ChangeOrganizationUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let changeOrganizationApiWorker: ChangeOrganizationApiWorker
   let getAuthMethodApiWork: Work<Void, AuthMethod>
   
   var work: Work<Int, AuthResult> { .init { work in
         let id = work.in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               RequestWithId(token: $0, id: id, vkAccessToken: nil)
            }
            .doNext(changeOrganizationApiWorker)
            .onSuccess {
               work.success($0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
