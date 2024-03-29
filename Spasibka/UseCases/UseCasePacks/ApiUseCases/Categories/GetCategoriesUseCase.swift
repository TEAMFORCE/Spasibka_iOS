//
//  CategoriesApiWork.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import ReactiveWorks

struct CategoriesResponse: Codable {
   let data: [CategoryData]
}

struct CategoryData: Codable, Identifiable, Tree {
   var depth: Int?

   let id: Int
   let name: String
   let children: [CategoryData]?

   init(id: Int, name: String, children: [CategoryData]?) {
      self.id = id
      self.name = name
      self.children = children
   }
}

struct GetCategoriesUseCase: UseCaseProtocol {
   let apiWorks: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: In<ChallengeTemplatesScope>.Out<CategoriesResponse> { .init { work in
      let request = work.in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let headers = makeCookiedTokenHeader(token)
            apiWorks.process(endpoint: SpasibkaEndpoints.GetCategories(
               headers: headers,
               body: ["scope": request.rawValue]
            ))
            .onSuccess { result in
               guard
                  let result = CategoriesResponse(result.data)
               else {
                  work.fail()
                  return
               }
               work.success(result)
            }
            .onFail {
               work.fail()
            }
         }
   }}
}
