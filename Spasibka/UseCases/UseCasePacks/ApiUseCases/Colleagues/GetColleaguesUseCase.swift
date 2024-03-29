//
//  GetColleaguesUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 21.02.2023.
//

import Foundation
import StackNinja

struct Colleague: Codable {
   let userId: Int
   let firstName: String?
   let surname: String?
   let tgName: String?
   let photo: String?
   let jobTitle: String?

   enum CodingKeys: String, CodingKey {
      case userId = "user_id"
      case firstName = "first_name"
      case surname
      case tgName = "tg_name"
      case photo
      case jobTitle = "job_title"
   }
}

struct GetColleaguesRequest: Codable {
   let name: String
   let departments: [Int]?
   let inOffice: Int
   let onHoliday: Int
   let firedAt: Int
}

struct GetColleaguesJsonData: Codable {
   let name: String
   let departments: [Int]?
   let inOffice: Int
   let onHoliday: Int
   let firedAt: Int
   let offset: Int
   let limit: Int

   enum CodingKeys: String, CodingKey {
      case name
      case inOffice = "in_office"
      case onHoliday = "on_holiday"
      case firedAt = "fired_at"
      case offset
      case limit
      case departments
   }
}

struct GetColleaguesUseCase: UseCaseProtocol {
   let apiEngine: ApiEngineProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<PaginationWithRequest<GetColleaguesRequest>, [Colleague]> {
      Work<PaginationWithRequest<GetColleaguesRequest>, [Colleague]>() { work in

         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               let cookieName = "csrftoken"
               guard
                  let pagination = work.input,
                  let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
               else {
                  print("No csrf cookie")
                  work.fail()
                  return
               }

               let jsonStruct = GetColleaguesJsonData(
                  name: pagination.request.name,
                  departments: pagination.request.departments,
                  inOffice: pagination.request.inOffice,
                  onHoliday: pagination.request.onHoliday,
                  firedAt: pagination.request.firedAt,
                  offset: pagination.offset,
                  limit: pagination.limit
               )
               let jsonData = try? JSONEncoder().encode(jsonStruct)

               self.apiEngine
                  .process(endpoint:
                     SpasibkaEndpoints.GetColleagues(
                        headers: [
                           Config.tokenHeaderKey: token,
                           "X-CSRFToken": cookie.value,
                           "Content-Type": "application/json",
                        ], jsonData: jsonData
                     ))
                  .done { result in
                     let decoder = DataToDecodableParser()
                     guard
                        let data = result.data,
                        let result: [Colleague] = decoder.parse(data)
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
