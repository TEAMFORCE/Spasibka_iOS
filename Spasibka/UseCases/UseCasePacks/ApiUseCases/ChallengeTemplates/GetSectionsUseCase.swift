////
////  GetSectionsUseCase.swift
////  Spasibka
////
////  Created by Yerzhan Gapurinov on 18.05.2023.
////
//
//import Foundation
//import ReactiveWorks
//import StackNinja
//
//struct ChallengeTemplateSection: Codable {
//   let id: Int
//   let createdAt: String?
//   let updatedAt: String?
//   let name: String?
//   let created: Int?
//   //let upperSection: Int?
//   let toLevelPublicity: Int?
//   
//   enum CodingKeys: String, CodingKey {
//      case id
//      case createdAt = "created_at"
//      case updatedAt = "updated_at"
//      case name, created
//      case toLevelPublicity = "to_level_publicty"
//   }
//}
//
//struct GetSectionsUseCase: UseCaseProtocol {
//   let apiEngine: ApiEngineProtocol
//   let safeStringStorage: StringStorageWorker
//
//   var work: Work<Int, [ChallengeTemplateSection]> {
//      Work<Int, [ChallengeTemplateSection]>() { work in
//
//         safeStringStorage
//            .doAsync(Config.tokenKey)
//            .onFail {
//               work.fail()
//            }
//            .onSuccess { token in
//               let cookieName = "csrftoken"
//               guard
//                  let challTemplateSectionId = work.input,
//                  let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
//               else {
//                  print("No csrf cookie")
//                  work.fail()
//                  return
//               }
//
//               self.apiEngine
//                  .process(endpoint:
//                     SpasibkaEndpoints.GetChallTemplateById(
//                        id: challTemplateSectionId.toString,
//                        headers: [
//                           Config.tokenHeaderKey: token,
//                           "X-CSRFToken": cookie.value,
//                           "Content-Type": "application/json",
//                        ]
//                     ))
//                  .done { result in
//                     let decoder = DataToDecodableParser()
//                     guard
//                        let data = result.data,
//                        let result: ChallengeTemplate = decoder.parse(data)
//                     else {
//                        work.fail()
//                        return
//                     }
//                     work.success(result: result)
//                  }
//                  .catch { _ in
//                     work.fail()
//                  }
//            }
//            .onSuccess {
//               work.success(result: $0)
//            }
//            .onFail {
//               work.fail()
//            }
//      }
//   }
//}
//
