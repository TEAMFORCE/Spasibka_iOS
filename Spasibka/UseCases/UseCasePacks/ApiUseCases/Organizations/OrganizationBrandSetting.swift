//
//  OrganizationBrandSettings.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.06.2023.
//

import Foundation

struct OrganizationBrandSettings: Codable {
   let name: String
   let telegramGroup: [String]
   let colorsJSON: ColorsJSON?
   let photo: String?
   let photo2: String?
   let settings: Settings?
   let licenseEnd: String?
   let botMessagesLifetime: Int?
   let botCommandsLifetime: Int?
   let bonusName: [String: PluralForms]?
   let loginLogo: String?
   let smallLogo: String?
   let menuLogo: String?

   enum CodingKeys: String, CodingKey {
      case name
      case telegramGroup = "telegram_group"
      case colorsJSON = "colors_json"
      case photo
      case photo2
      case settings
      case licenseEnd = "license_end"
      case botMessagesLifetime = "bot_messages_lifetime"
      case botCommandsLifetime = "bot_commands_lifetime"
      case bonusName = "bonusname"

      case loginLogo = "login_logo"
      case smallLogo = "small_logo"
      case menuLogo = "menu_logo"
   }
}

struct ColorsJSON: Codable {
   let brand: String?
   let brandSecondary: String?
   let contrast: String?
   let contrastSecondary: String?
   let negative: String?
   let negativeSecondary: String?
   let midpoint: String?
   let success: String?
   let successSecondary: String?
   let error: String?
   let errorSecondary: String?
   let warning: String?
   let warningSecondary: String?
   let info: String?
   let infoSecondary: String?
   let extra1: String?
   let extra2: String?

   enum CodingKeys: String, CodingKey {
      case brand = "general-brand"
      case brandSecondary = "general-brand-secondary"

      case contrast = "general-contrast"
      case contrastSecondary = "general-contrast-secondary"

      case negative = "general-negative"
      case negativeSecondary = "minor-negative-secondary"

      case midpoint = "general-midpoint"

      case success = "minor-success"
      case successSecondary = "minor-success-secondary"

      case error = "minor-error"
      case errorSecondary = "minor-error-secondary"

      case warning = "minor-warning"
      case warningSecondary = "minor-warning-secondary"

      case info = "minor-info"
      case infoSecondary = "minor-info-secondary"

      case extra1 = "extra1"
      case extra2 = "extra2"
   }
}

struct Settings: Codable {
   let tGracePeriod: DefaultSettingsValue
   let pDistr: PDistr
   let botMessagesLifetime: DefaultSettingsValue
   let tagsIgnoreGlobal: DefaultSettingsValue
   let tagsAllowed: DefaultSettingsValue
   let showLocation: DefaultSettingsValue
   let botCommandsLifetime: DefaultSettingsValue
   let tagsValuesAllowed: DefaultSettingsValue

   enum CodingKeys: String, CodingKey {
      case tGracePeriod = "t_grace_period"
      case pDistr = "p_distr"
      case botMessagesLifetime = "bot_messages_lifetime"
      case tagsIgnoreGlobal = "tags_ignore_global"
      case tagsAllowed = "tags_allowed"
      case showLocation = "show_location"
      case botCommandsLifetime = "bot_commands_lifetime"
      case tagsValuesAllowed = "tags_values_allowed"
   }
}

struct DefaultSettingsValue: Codable {
   let defaultSettingsValue: String

   enum CodingKeys: String, CodingKey {
      case defaultSettingsValue = "default_settings_value"
   }
}

struct PDistr: Codable {
   let usersSettingsValues: [UserSettingsValue]
   let defaultSettingsValue: String

   enum CodingKeys: String, CodingKey {
      case usersSettingsValues = "users_settings_values"
      case defaultSettingsValue = "default_settings_value"
   }
}

struct UserSettingsValue: Codable {
   let userId: Int
   let userName: String
   let userSurname: String
   let userTgName: String
   let userNickname: String
   let value: String

   enum CodingKeys: String, CodingKey {
      case userId = "user_id"
      case userName = "user_name"
      case userSurname = "user_surname"
      case userTgName = "user_tg_name"
      case userNickname = "user_nickname"
      case value
   }
}
