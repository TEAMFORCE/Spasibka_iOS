//
//  CreateCategoryUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.07.2023.
//

import ReactiveWorks
import Foundation

struct CreateCategoryRequestBody: Codable {
   let name: String
   let upperSections: [Int]
   let scope: Int
}

extension CreateCategoryRequestBody {
   enum CodingKeys: String, CodingKey {
      case name
      case upperSections = "upper_sections"
      case scope
   }
}

struct CreateCategoryResponse: Decodable {
   let id: Int?
   let name: String
   let upperSection: Int?

   enum CodingKeys: String, CodingKey {
      case id
      case name
      case upperSection = "upper_section"
   }
}

struct CreateCategoryUseCase: UseCaseProtocol {
   let apiWorks: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: In<CreateCategoryRequestBody>.Out<CreateCategoryResponse> { .init { work in
      let request = work.in
      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let headers = makeCookiedTokenHeader(token)
            apiWorks.process(endpoint: SpasibkaEndpoints.CreateCategory(
               headers: headers,
               jsonData: request.jsonData
            ))
            .onSuccess { response in
               guard let result = CreateCategoryResponse(response.data) else {
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

