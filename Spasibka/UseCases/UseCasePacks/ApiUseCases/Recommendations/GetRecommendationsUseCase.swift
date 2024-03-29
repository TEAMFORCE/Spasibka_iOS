//
//  GetRecommendationsUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 06.02.2024.
//

import StackNinja

struct RecommendationsResponse: Codable {
   let status: Int?
   let data: [Recommendation]?
}

struct Recommendation: Codable {
   let id: Int?
   let name: String?
   let header: String?
   let type: RecType?
   let marketplaceId: Int?
   let photos: [String]?
   let isNew: Bool?
   
   enum CodingKeys: String, CodingKey {
      case id
      case name
      case header
      case type
      case marketplaceId = "marketplace_id"
      case photos
      case isNew = "is_new"
   }
   
   enum RecType: String, Codable {
      case questionnaire = "questionnaire"
      case chain = "chain"
      case challenge = "challenge"
      case offer = "offer"
   }
}

struct GetRecommendationsUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker
   
   var work: Work<Void, [Recommendation]> { .init { work in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let endpoint = SpasibkaEndpoints.GetRecommendations(headers: makeCookiedTokenHeader(token))
            
            self.apiEngine
               .process(endpoint: endpoint)
               .onSuccess { result in
                  guard
                     let response = RecommendationsResponse(result.data)
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
         .onFail {
            work.fail()
         }
   } }
}
