//
//  UserData.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import Foundation

struct UserData: Codable {
   let userName: String
   let profile: Profile
   let privileged: [Privilege]
   let rate: Int?
   let id: Int?

   enum CodingKeys: String, CodingKey {
      case userName = "username"
      case profile
      case privileged
      case rate
      case id
   }

   struct Profile: Codable {
      let id: Int
      let contacts: [Contact]?
      let organization: String
      let organizationId: Int?
      let department: String
      let tgId: String?
      let tgName: String?
      let photo: String?
      let hiredAt: String?
      let surName: String?
      let firstName: String?
      let middleName: String?
      let nickName: String?
      let jobTitle: String?
      let status: String?
      let secondaryStatus: String?
      let birthDate: String?
      let gender: Gender?
      let showBirthday: Bool?
      let language: String?

      enum CodingKeys: String, CodingKey {
         case id
         case contacts
         case organization
         case organizationId = "organization_id"
         case department
         case tgId = "tg_id"
         case tgName = "tg_name"
         case photo
         case hiredAt = "hired_at"
         case surName = "surname"
         case firstName = "first_name"
         case middleName = "middle_name"
         case nickName = "nickname"
         case jobTitle = "job_title"
         case status
         case secondaryStatus = "secondary_status"
         case birthDate = "date_of_birth"
         case gender
         case showBirthday = "show_birthday"
         case language
      }
   }
}

enum Gender: String, Codable {
   case W
   case M
   case NotSelected = ""

   init(index: Int) {
      switch index {
      case 0:
         self = .W
      case 1:
         self = .M
      default:
         self = .NotSelected
      }
   }

   var textForGender: String {
      Self.allGenderTexts[index]
   }

   var index: Int {
      switch self {
      case .W:
         return 0
      case .M:
         return 1
      case .NotSelected:
         return 2
      }
   }

   static var allGenderTexts: [String] { [
      DesignSystem.text.woman,
      DesignSystem.text.man,
      DesignSystem.text.notIndicated,
   ] }
}

struct Contact: Codable {
   let id: Int
   let contactType: String
   let contactId: String

   enum CodingKeys: String, CodingKey {
      case id
      case contactType = "contact_type"
      case contactId = "contact_id"
   }
}

struct Privilege: Codable {
   let roleName: String
   let role: String
   let departmentName: String?

   enum CodingKeys: String, CodingKey {
      case roleName = "role_name"
      case role
      case departmentName = "department_name"
   }
}

extension UserData {
   var userEmail: String? {
      profile.contacts?.first(where: {
         $0.contactType == "@"
      })?.contactId
   }

   var userPhone: String? {
      profile.contacts?.first(where: {
         $0.contactType == "P"
      })?.contactId
   }
}
