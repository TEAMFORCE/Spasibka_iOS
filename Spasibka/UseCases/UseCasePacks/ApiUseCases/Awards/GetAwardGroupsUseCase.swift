//
//  GetAwardGroupsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 01.11.2023.
//

import StackNinja

struct AwardGroup: Codable {
   let id: Int
   let name: String?
}

struct AwardGroupsRequestResult: Codable {
   let status: Int?
   let data: [AwardGroup]?
}

struct GetAwardGroupsUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<Int, [AwardGroup]> { .init { work in
      let input = work.in
      
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let endpoint = SpasibkaEndpoints.GetAwardGroups(
               headers: makeCookiedTokenHeader(token)) {
               input.toString
            }
            self.apiEngine
               .process(endpoint: endpoint)
               .onSuccess { result in
                  guard
                     let response = AwardGroupsRequestResult(result.data)
                  else {
                     work.fail()
                     return
                  }
                  work.success(result: response.data ?? [])
               }
               .onFail {
                  work.fail()
               }
         }
   } }
}
