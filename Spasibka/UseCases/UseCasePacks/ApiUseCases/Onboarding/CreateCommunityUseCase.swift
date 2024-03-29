//
//  CreateCommunityUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 30.05.2023.
//

import Foundation
import StackNinja
import UIKit

struct CommunityRequest: Codable {
   let name: String
}

struct CommunityWithParamsRequest: Codable {
   let organizationName: String
   let periodStartDate: String
   let periodEndDate: String
   let usersStartBalance: Int
   let ownerStartBalance: Int
}

extension CommunityWithParamsRequest {
   enum CodingKeys: String, CodingKey {
      case organizationName = "organization_name"
      case periodStartDate = "period_start_date"
      case periodEndDate = "period_end_date"
      case usersStartBalance = "users_start_balance"
      case ownerStartBalance = "owner_start_balance"
   }
}

struct CommunityResponse: Codable {
   let status: String?
   let text: String?
   let organizationId: Int?
   let inviteLink: String?
}

extension CommunityResponse {
   enum CodingKeys: String, CodingKey {
      case status
      case text
      case organizationId = "organization_id"
      case inviteLink = "invite_link"
   }
}

struct CreateCommunityUseCase: UseCaseProtocol {
   let apiEngine: ApiEngineProtocol
   let safeStringStorage: StringStorageWorker

   var work: Work<CommunityRequest, CommunityResponse> {
      Work<CommunityRequest, CommunityResponse>() { work in

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
               let endpoint = SpasibkaEndpoints.Community(
                  headers: [
                     Config.tokenHeaderKey: token,
                     "X-CSRFToken": cookie.value
                  ], body: body
               )

               self.apiEngine
                  .process(endpoint: endpoint)
                  .done { result in
                     guard
                        let result: CommunityResponse = .init(result.data)
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
