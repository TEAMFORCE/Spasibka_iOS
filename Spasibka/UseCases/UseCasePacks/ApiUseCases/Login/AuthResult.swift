//
//  AuthResult.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import Foundation

enum Auth2Result {
   case auth(AuthResult)
   case existUser([OrganizationAuth])
   case newUser(AuthNewUserResult)
}

struct AuthNewUserResult: Codable {
   let target: String?
   let status: String?
   let transition: Bool?
   let xEmail: String?
   let xTelegram: String?
   let xCode: String?

   enum CodingKeys: String, CodingKey {
      case target
      case status
      case transition
      case xEmail = "x-email"
      case xTelegram = "x-telegram"
      case xCode = "x-code"
   }
}

enum Account {
   case telegram
   case email
}

struct AuthResult {
   let xId: String
   let xCode: String
   let account: Account
   let organizationId: String?
   let vkAccessToken: String?

   init(xId: String,
        xCode: String,
        account: Account,
        organizationId: String? = nil,
        vkAccessToken: String? = nil)
   {
      self.xId = xId
      self.xCode = xCode
      self.account = account
      self.organizationId = organizationId
      self.vkAccessToken = vkAccessToken
   }
}

struct AuthResultBody: Decodable {
   let type: String?
   let status: String?
   let error: String?
}

struct SoloOrgResult: Codable {
   let status: String?
   let organizations: [OrganizationAuth]
}

struct OrganizationAuth: Codable {
   let userId: Int
   let organizationId: Int
   let organizationName: String?
   let organizationPhoto: String?

   enum CodingKeys: String, CodingKey {
      case userId = "user_id"
      case organizationId = "organization_id"
      case organizationName = "organization_name"
      case organizationPhoto = "organization_photo"
   }
}


