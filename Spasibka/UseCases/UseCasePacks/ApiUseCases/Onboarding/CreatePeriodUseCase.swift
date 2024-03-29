//
//  CreatePeriodUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 30.05.2023.
//

import Foundation
import StackNinja
import UIKit

struct PeriodRequest: Codable {
   let startDate: String
   let endDate: String
   let `default`: Bool?
   let distrAmount: Int
   let headDistrAmount: Int
   let organizationId: Int?
}

extension PeriodRequest {
   enum CodingKeys: String, CodingKey {
      case startDate = "start_date"
      case endDate = "end_date"
      case `default` = "default"
      case distrAmount = "distr_amount"
      case headDistrAmount = "head_distr_amount"
      case organizationId = "organization_id"
   }
}

struct PeriodRequestResponse: Codable {
   let id: Int?
   let startDate: String?
   let endDate: String?
   let organizationId: Int?
}

extension PeriodRequestResponse {
   enum CodingKeys: String, CodingKey {
      case id
      case startDate = "start_date"
      case endDate = "end_date"
      case organizationId = "organization_id"
   }
}

struct CreatePeriodUseCase: UseCaseProtocol {
   let apiEngine: ApiEngineProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<PeriodRequest, PeriodRequestResponse> {
      Work<PeriodRequest, PeriodRequestResponse>() { work in

         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               let cookieName = "csrftoken"
               guard
                  let request = work.input,
                  let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
               else {
                  print("No csrf cookie")
                  work.fail()
                  return
               }
               let body = request.dictionary ?? [:]
               let endpoint = SpasibkaEndpoints.CreatePeriod(
                  headers: [
                     Config.tokenHeaderKey: token,
                     "X-CSRFToken": cookie.value
                  ], body: body
               )

               self.apiEngine
                  .process(endpoint: endpoint)
                  .done { result in
                     guard
                        let result: PeriodRequestResponse = .init(result.data)
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
      }
   }
}
