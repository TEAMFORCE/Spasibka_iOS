//
//  ChallengeSettingsInput.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import Foundation

final class ChallengeSettings {
   var severalReports: Bool = true
   var showContenders: Bool = true

   var selectedChallengeTypeIndex: Int = 0
   var selectedAccountTypeIndex: Int?

   let params: ChallengeCreateLoadedParams
   let mode: Mode

   init(settings: CreateChallengeSettings, mode: Mode) {
      var fondAccounts = [ChallengeCreateLoadedParams.FondType]()
      if let personalAccounts = settings.accounts?.personalAccounts {
         for item in personalAccounts {
            fondAccounts.append(.personal(item))
         }
      }
      if let orgAccounts = settings.accounts?.organizationAccounts {
         for item in orgAccounts {
            fondAccounts.append(.organization(item))
         }
      }

      var challTypes: [ChallengeCreateLoadedParams.ChallengeType] = []
      if settings.types?.default == 1 {
         challTypes.append(.default)
      }
      if settings.types?.voting == 2 {
         challTypes.append(.voting)
      }
      let params = ChallengeCreateLoadedParams(
         challengeTypes: challTypes,
         fondAccounts: fondAccounts
      )

      self.params = params
      self.mode = mode
   }

   enum Mode {
      case challengeSettings
      case templateSettings
   }
}

extension ChallengeSettings {
   func setCurrentChallengeTypeForName(_ challengeTypeName: String?) {
      let selectedChallengeType = ChallengeCreateLoadedParams.ChallengeType(name: challengeTypeName)
      switch selectedChallengeType {
      case .default:
         selectedChallengeTypeIndex = 0
      case .voting:
         selectedChallengeTypeIndex = 1
      case .none:
         selectedChallengeTypeIndex = 0
      }
   }

   var selectedChallengeType: ChallengeCreateLoadedParams.ChallengeType? {
      params.challengeTypes[selectedChallengeTypeIndex]
   }

   var selectedChallengeTypeName: String? {
      guard let type = params.challengeTypes[safe: selectedChallengeTypeIndex] else { return "default" }

      switch type {
      case .default:
         return "default"
      case .voting:
         return "voting"
      }
   }

   var payerAccountId: Int? {
      guard let type = params.fondAccounts[safe: selectedAccountTypeIndex ?? 0] else { return nil }

      switch type {
      case let .personal(fond):
         return fond.id
      case let .organization(fond):
         return fond.id
      }
   }
}

extension Bool {
   var yesNo: String {
      self ? "yes" : "no"
   }
}

extension String {
   var yesNo: Bool {
      self == "yes"
   }
}

struct ChallengeCreateLoadedParams {
   let challengeTypes: [ChallengeType]
   let fondAccounts: [FondType]

   enum ChallengeType: Int {
      case `default` = 1
      case voting = 2

      init?(name: String?) {
         if name == "default" {
            self = .default
         } else if name == "voting" {
            self = .voting
         } else {
            return nil
         }
      }
   }

   enum FondType {
      case personal(FondAccount)
      case organization(FondAccount)
   }
}
