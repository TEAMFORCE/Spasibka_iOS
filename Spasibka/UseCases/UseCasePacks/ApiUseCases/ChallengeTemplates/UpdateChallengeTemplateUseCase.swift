//
//  UpdateChallengeTemplateUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.07.2023.
//

import StackNinja
import UIKit

struct UpdateChalleneTemplateRequest: Encodable {
   let name: String
   let description: String
   let challengeTemplate: Int
   let scope: Int?
   let sections: String?
   let challengeType: String?
   let multipleReports: String?
   let showContenders: String?
   let photo: UIImage?

   enum CodingKeys: String, CodingKey {
      case challengeTemplate = "challenge_template"
      case scope
      case sections
      case name
      case description
      case challengeType = "challenge_type"
      case multipleReports = "multiple_reports"
      case showContenders = "show_contenders"
   }

   init(name: String, description: String, challengeTemplate: Int,
        scope: Int?, sections: [Int]?,
        challengeType: String?, multipleReports: String?,
        showContenders: String?, photo: UIImage?)
   {
      self.name = name
      self.description = description
      self.challengeTemplate = challengeTemplate
      self.scope = scope
      self.sections = sections?.compactMap { String($0) }.joined(separator: ",")
      self.challengeType = challengeType
      self.multipleReports = multipleReports
      self.showContenders = showContenders
      self.photo = photo
   }
}

struct UpdateChallengeTemplateUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<UpdateChalleneTemplateRequest, ChallengeTemplate> { .init { work in

      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let request = work.in
            let header = makeCookiedTokenHeader(token)

            var body = request.dictionary ?? [:]
            body["photo"] = nil // TODO: - remove this line when backend will be ready
            let endpoint = SpasibkaEndpoints.UpdateChallengeTemplate(
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
