//
//  CreateChallengeTemplate.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 18.05.2023.
//

import Foundation
import StackNinja
import UIKit

struct CreateChallTemplateRequest: Encodable {
   let scope: Int?
   let name: String
   let sections: String?
   let showContenders: String?
   let description: String
   let challengeType: String?
   let multipleReports: String?
   let photo: UIImage?

   init(
      scope: Int? = nil,
      name: String,
      sections: [Int]? = nil,
      showContenders: String?,
      description: String,
      challengeType: String? = nil,
      multipleReports: String? = nil,
      photo: UIImage? = nil
   ) {
      self.scope = scope
      self.name = name
      self.sections = sections?.compactMap { String($0) }.joined(separator: ",")
      self.showContenders = showContenders
      self.description = description
      self.challengeType = challengeType
      self.multipleReports = multipleReports
      self.photo = photo
   }
}

extension CreateChallTemplateRequest {
   enum CodingKeys: String, CodingKey {
      case scope, name, sections
      case showContenders = "show_contenders"
      case description
      case challengeType = "challenge_type"
      case multipleReports = "multiple_reports"
   }
}

struct CreateChallengeTemplateUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<CreateChallTemplateRequest, ChallengeTemplate> {
      Work<CreateChallTemplateRequest, ChallengeTemplate>() { work in

         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               let request = work.in
               let header = makeCookiedTokenHeader(token)

               let body = request.dictionary ?? [:]
               let endpoint = SpasibkaEndpoints.CreateChallengeTemplate(
                  headers: header, body: body
               )

               if let photo = request.photo {
                  let names = [String](repeating: "photo", count: 1)
                  self.apiEngine
                     .processWithImages(endpoint: endpoint,
                                        images: [photo],
                                        names: names)
                     .onSuccess { result in
                        guard
                           let result = ChallengeTemplate(result.data)
                        else {
                           work.fail()
                           return
                        }
                        work.success(result: result)
                     }
                     .onFail {
                        work.fail()
                     }
               } else {
                  self.apiEngine
                     .process(endpoint: endpoint)
                     .onSuccess { result in
                        guard
                           let result = ChallengeTemplate(result.data)
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
            }
      }
   }
}
