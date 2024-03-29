//
//  EditChallengeUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 11.08.2023.
//

import StackNinja
import UIKit

struct ChallengeUpdateResponse: Codable {
   let status: Int?
   let details: String?
   let errors: String?
}

struct FileList: Encodable {
   let sortIndex: Int
   let index: Int?
   let filename: String?
   var image: UIImage?

   enum CodingKeys: String, CodingKey {
      case sortIndex
      case index
      case filename
   }
}

struct ChallengeEditRequest: Encodable {
   let name: String?
   let description: String?
   let startAt: String?
   let endAt: String?
   let startBalance: Int?
   let accountId: Int?
   let challengeType: String?
   let multipleReports: Bool?
   let winnersCount: Int?
   let showContenders: Bool?
   let fileList: [FileList]?

   init(name: String? = nil,
        description: String? = nil,
        startAt: String? = nil,
        endAt: String? = nil,
        startBalance: Int? = nil,
        accountId: Int? = nil,
        challengeType: String? = nil,
        multipleReports: Bool? = nil,
        winnersCount: Int? = nil,
        showContenders: Bool? = nil,
        fileList: [FileList]? = nil)
   {
      self.name = name
      self.description = description
      self.startAt = startAt
      self.endAt = endAt
      self.startBalance = startBalance
      self.accountId = accountId
      self.challengeType = challengeType
      self.multipleReports = multipleReports
      self.winnersCount = winnersCount
      self.showContenders = showContenders
      self.fileList = fileList
   }
}

extension ChallengeEditRequest {
   enum CodingKeys: String, CodingKey {
      case name, description
      case startAt = "start_at"
      case endAt = "end_at"
      case startBalance = "start_balance"
      case accountId = "account_id"
      case challengeType = "challenge_type"
      case multipleReports = "multiple_reports"
      case winnersCount = "winners_count"
      case showContenders = "show_contenders"
      case fileList
   }
}

struct UpdateChallengeUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<(Int, ChallengeEditRequest), ChallengeUpdateResponse> { .init { work in

      safeStringStorage
         .doAsync(Config.tokenKey)
         .onFail {
            work.fail()
         }
         .onSuccess { token in
            let id = work.in.0
            let fileList = work.in.1.fileList
            let header = makeCookiedTokenHeader(token)

            let body = work.in.1.dictionary ?? [:]
            let endpoint = SpasibkaEndpoints.UpdateChallenge(
               body: body,
               headers: header,
               interpolateFunction: { String(id) }
            )

            if let fileList {
               let photos = fileList.filter {
                  $0.image != nil
               }
               .map {
                  ($0.image?.sideLengthLimited(to: Config.imageSendSize) ?? UIImage(), $0.filename.string)
               }

               self.apiEngine
                  .processWithImages(endpoint: endpoint, images: photos.map(\.0), names: photos.map(\.1))
                  .onSuccess { result in
                     guard
                        let result = ChallengeUpdateResponse(result.data)
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
                        let result = ChallengeUpdateResponse(result.data)
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
