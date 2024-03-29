//
//  GetChallengeGroupsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 07.09.2023.
//

import StackNinja

enum ChalengeGroupState: String {
   case active = "A"
   case deffered = "D"
   case closed = "C"

   var key: String { "current_state" }
}

struct ChallengeGroupRequest {
   let orgId: Int
   let state: ChalengeGroupState
}

struct ChallengeGroupResponse: Codable {
   let data: [ChallengeGroup]?
}

struct ChallengeGroup: Codable {
   let id: Int?
   let name: String?
   let description: String?
   let author: String?
   let authorId: Int?
   let authorPhoto: String?
   let photos: [String]?
   let updatedAt: String?
   let startAt: String?
   let endAt: String?
   let contendersTotal: Int?
   let commentsTotal: Int?
   let tasksTotal: Int?
   let tasksFinished: Int?
   let stateCondition: String?

   var currentState: ChallengeCondition? {
      ChallengeCondition(rawValue: stateCondition ?? "")
   }
}

extension ChallengeGroup: Hashable {
   func hash(into hasher: inout Hasher) {
      hasher.combine(id)
   }
}

extension ChallengeGroup {
   enum CodingKeys: String, CodingKey {
      case id, name, author, description
      case authorId = "author_id"
      case authorPhoto = "author_photo"
      case photos
      case updatedAt = "updated_at"
      case startAt = "start_at"
      case endAt = "end_at"
      case contendersTotal = "contenders_total"
      case commentsTotal = "comments_total"
      case tasksTotal = "tasks_total"
      case tasksFinished = "tasks_finished"
      case stateCondition = "current_state"
   }
}

struct GetChallengeGroupsUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<PaginationWithRequest<ChallengeGroupRequest>, [ChallengeGroup]> { .init { work in
         let input = work.in
         let request = input.request

         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               let endpoint = SpasibkaEndpoints.GetChallengeGroups(
                  headers: makeCookiedTokenHeader(token))
               {
                  "\(request.orgId)/challenges/groups/"
                  + "?limit=\(input.limit)&offset=\(input.offset)"
                  + "&\(request.state.key)=\(request.state.rawValue)"
               }
               self.apiEngine
                  .process(endpoint: endpoint)
                  .onSuccess { result in
                     guard
                        let response = ChallengeGroupResponse(result.data)
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
      }
   }
}
