//
//  GetChallengeGroupByIdUsecase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 07.09.2023.
//

import StackNinja

struct GroupIdRequest {
   let organizationId: Int
   let groupId: Int
}

struct GetChallengeGroupByIdUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<GroupIdRequest, ChallengeGroup> {
      Work<GroupIdRequest, ChallengeGroup>() { work in
         let input = work.in
         
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               let endpoint = SpasibkaEndpoints.GetChallengeGroupById(
                  headers: makeCookiedTokenHeader(token)) {
                     "\(input.organizationId)/challenges/groups/\(input.groupId)"
               }
               self.apiEngine
                  .process(endpoint: endpoint)
                  .onSuccess { result in
                     guard
                        let res = ChallengeGroup(result.data)
                     else {
                        work.fail()
                        return
                     }
                     work.success(result: res)
                  }
                  .onFail {
                     work.fail()
                  }
            }
      }
   }
}
