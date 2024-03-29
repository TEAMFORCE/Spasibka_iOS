//
//  GetChallTemplateByIdUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 18.05.2023.
//

import Foundation
import StackNinja

struct ChallengeTemplate: Codable {
   struct Section: Codable {
      let id: Int
      let name: String
   }

   let id: Int?
   let name: String?
   let description: String?
   let photo: String?
   let parameters: [String]?
   let status: [String]?
   let multipleReports: Bool?
   let showContenders: Bool?
   let challengeType: String?
   let sections: [Section]?
}

extension ChallengeTemplate {
   enum CodingKeys: String, CodingKey {
      case id, name, description, photo, parameters, status
      case multipleReports = "multiple_reports"
      case showContenders = "show_contenders"
      case challengeType = "challenge_type"
      case sections
   }
}

struct GetChallTemplateByIdUseCase: UseCaseProtocol {
   let apiEngine: ApiEngineProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<Int, ChallengeTemplate> {
      Work<Int, ChallengeTemplate>() { work in

         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               let cookieName = "csrftoken"
               guard
                  let challTemplateId = work.input,
                  let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
               else {
                  print("No csrf cookie")
                  work.fail()
                  return
               }

               self.apiEngine
                  .process(endpoint:
                     SpasibkaEndpoints.GetChallTemplateById(
                        id: challTemplateId.toString,
                        headers: [
                           Config.tokenHeaderKey: token,
                           "X-CSRFToken": cookie.value,
                           "Content-Type": "application/json",
                        ]
                     ))
                  .done { result in
                     let decoder = DataToDecodableParser()
                     guard
                        let data = result.data,
                        let result: ChallengeTemplate = decoder.parse(data)
                     else {
                        work.fail()
                        return
                     }
                     work.success(result: result)
                  }
                  .catch { _ in
                     work.fail()
                  }
            }
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}

