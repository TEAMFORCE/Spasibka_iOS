//
//  DeleteChallTemplateUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 16.08.2023.
//

import ReactiveWorks

struct DeleteChallengeTemplateUseCase: UseCaseProtocol {
   let apiWorks: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: In<Int>.Out<Void> { .init { work in
      let request = work.in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let headers = makeCookiedTokenHeader(token)
            apiWorks.process(endpoint: SpasibkaEndpoints.DeleteChallengeTemplate(
               body: ["challenge_template": request.toString],
               headers: headers))
            .onSuccess { _ in
               work.success()
            }
            .onFail {
               work.fail()
            }
         }
   }}

}
