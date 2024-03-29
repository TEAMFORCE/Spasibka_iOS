//
//  GetChallengeTemplates.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 19.05.2023.
//

import Foundation
import StackNinja

struct GetChallengeTemplatesUseCase: UseCaseProtocol {
   let apiEngine: ApiEngineProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<PaginationWithRequest<Int>, [ChallengeTemplate]> { .init { work in

      let scope = work.in.request

      let paginationLimit = work.in.limit
      let paginationOffset = work.in.offset

      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let cookieName = "csrftoken"
            guard
               let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
            else {
               print("No csrf cookie")
               work.fail()
               return
            }

            self.apiEngine
               .process(endpoint:
                  SpasibkaEndpoints.GetChallengeTemplates(
                     scope: scope.toString,
                     offset: paginationOffset,
                     limit: paginationLimit,
                     headers: [
                        Config.tokenHeaderKey: token,
                        "X-CSRFToken": cookie.value,
                        "Content-Type": "application/json",
                     ]
                  ))
               .done { result in
                  guard
                     let result: [ChallengeTemplate] = .init(result.data)
                  else {
                     work.fail()
                     return
                  }
                  work.success(result: result)
               }
               .catch { _ in
                  work.fail()
               }
         }
         .onFail {
            work.fail()
         }
   } }
}
