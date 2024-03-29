//
//  GetAwardsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 02.11.2023.
//

import StackNinja

struct AwardsRequestResult: Codable {
   let status: Int?
   let data: [Award]?
}
struct Award: Codable {
   let id: Int
   let name: String?
   var cover: String?
   let reward: Int?
   let toScore: Int?
   let description: String?
   let scored: Int?
   let received: Bool?
   let categoryId: Int?
   let categoryName: String?

   var coverFullUrlString: String? { SpasibkaEndpoints.tryConvertToImageUrl(cover) }
}

extension Award {
   enum CodingKeys: String, CodingKey {
      case id, name, cover, reward
      case toScore = "to_score"
      case description, scored, received
      case categoryId = "category_id"
      case categoryName = "category_name"
   }
}

struct GetAwardsUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<Int, [Award]> { .init { work in
      let input = work.in
      
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let endpoint = SpasibkaEndpoints.GetAwards(
               headers: makeCookiedTokenHeader(token)) {
               input.toString
            }
            self.apiEngine
               .process(endpoint: endpoint)
               .onSuccess { result in
                  guard
                     let response = AwardsRequestResult(result.data)
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
