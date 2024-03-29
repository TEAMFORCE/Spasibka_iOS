//
//  GetTransactionsByGroupUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 28.09.2023.
//

import StackNinja

struct TransactionByGroup: Codable {
   let userId: Int?
   let date: String?
   let received: Int?
   let waiting: Int?
   let ready: Int?
   let userPhoto: String?
   let firstName: String?
   let surname: String?
   let tgName: String?
   let nickname: String?
}

struct TransactionsGroupResponse: Codable {
   let data: [TransactionByGroup]?
}

extension TransactionByGroup {
   enum CodingKeys: String, CodingKey {
      case userId = "user_id"
      case date, received, waiting, ready
      case userPhoto = "user_photo"
      case firstName = "first_name"
      case surname = "surname"
      case tgName = "tg_name"
      case nickname
   }
}

struct GetTransactionsByGroupUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<Pagination, [TransactionByGroup]> { .init { work in
      let input = work.in
      

      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let endpoint = SpasibkaEndpoints.GetTransactionsByGroup(
               headers: makeCookiedTokenHeader(token))
            {
               "?limit=\(input.limit)&offset=\(input.offset)"
            }
            self.apiEngine
               .process(endpoint: endpoint)
               .onSuccess { result in
                  guard
                     let response = TransactionsGroupResponse(result.data)
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
