//
//  LikeApiUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.07.2023.
//

import StackNinja
import Foundation

struct LikeApiRequest {
   let isLike: Bool
   let id: Int
   let objectType: FeedEventSelector

   var body: [String: Any] {
      var type: String

      switch objectType {
      case .transaction:
         type = "transaction_id"
      case .challenge:
         type = "challenge_id"
      case .winner:
         type = "challenge_report_id"
      case .market:
         type = "order_id"
      }

      let body = [
         type: id,
         "like_kind": isLike ? 1 : 2
      ]

      return body
   }
}

struct LikeApiUseCase: UseCaseProtocol {
   let apiWorks: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work:  In<LikeApiRequest>.Out<PressLikeResult> { .init { work in
      let request = work.in

      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess {
            let headers = makeCookiedTokenHeader($0)
            self.apiWorks
               .process(endpoint: SpasibkaEndpoints.PressLike(headers: headers, body: request.body))
               .onSuccess {
                  guard
                     let result = PressLikeResult($0.data)
                  else {
                     work.fail()
                     return
                  }
                  work.success(result: result)
               }
               .onFail {
                  work.fail()
               }
         }
   }}
}
