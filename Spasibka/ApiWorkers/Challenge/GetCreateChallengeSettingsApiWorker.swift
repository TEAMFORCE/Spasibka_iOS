//
//  CreateChallengeGetApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 06.12.2022.
//

import Foundation
import StackNinja

struct CreateChallengeSettings: Codable {
   let types: ChallengeType?
   let accounts: BalanceAccounts?

   let showParticipants: String?
   let severalReports: String?
}

struct ChallengeType: Codable {
   let `default`: Int?
   let voting: Int?
}

struct BalanceAccounts: Codable {
   let organizationAccounts: [FondAccount]?
   let personalAccounts: [FondAccount]?

   enum CodingKeys: String, CodingKey {
      case organizationAccounts = "organization_accounts"
      case personalAccounts = "personal_accounts"
   }
}

struct FondAccount: Codable {
   let id: Int?
   let accountType: String?
   let amount: Double?
   let ownerId: Int?
   let organizationName: String?

   enum CodingKeys: String, CodingKey {
      case id
      case accountType = "account_type"
      case amount
      case ownerId = "owner_id"
      case organizationName = "organization_name"
   }
}

final class GetCreateChallengeSettingsApiWorker: BaseApiWorker<String, CreateChallengeSettings> {
   override func doAsync(work: Wrk) {
      let headers = makeCookiedTokenHeader(work.in)
      let endpoint = SpasibkaEndpoints.CreateChallengeGet(headers: headers)
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            guard
               let settings = CreateChallengeSettings(result.data)
            else {
               work.fail()
               return
            }
            work.success(result: settings)
         }
         .catch { _ in
            work.fail()
         }
   }
}
