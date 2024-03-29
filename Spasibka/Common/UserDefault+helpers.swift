//
//  UserDefault+helpers.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 28.07.2022.
//

import Foundation

enum UserDefaultsKeys: String {
   case isLoggedIn
   case urlBase
   case colorSchemeKey
   case markerFilterParams
   case isUserPrivacyApplied
   case userPrivacyAppliedForUserName
   case currentOrganizationID
   case inviteLink
   case organizationBrandConfiguration
   case appLanguage
   case userData
   case challengeId
}

protocol UserDefaultsStorageProtocol {
   func setIsLoggedIn(value: Bool)
   func isLoggedIn() -> Bool

   @discardableResult
   func saveValue<T: Codable>(_ value: T, forKey key: UserDefaultsKeys) -> Bool
   func loadValue<T: Decodable>(forKey key: UserDefaultsKeys) -> T?

   func saveString(_ value: String, forKey key: UserDefaultsKeys)
   func loadString(forKey key: UserDefaultsKeys) -> String?

   func clearForKey(_ key: UserDefaultsKeys)

   @discardableResult
   func saveValue<T: Codable>(_ value: T, forKey key: any Hashable) -> Bool
   func loadValue<T: Decodable>(forKey key: any Hashable) -> T?
   func clearForKey(_ key: any Hashable)
}

extension UserDefaults: UserDefaultsStorageProtocol {
   func setIsLoggedIn(value: Bool) {
      set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
      synchronize()
   }

   func isLoggedIn() -> Bool {
      bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
   }

   @discardableResult
   func saveValue<T: Codable>(_ value: T, forKey key: UserDefaultsKeys) -> Bool {
      let encoder = JSONEncoder()
      if let encoded = try? encoder.encode(value) {
         UserDefaults.standard.set(encoded, forKey: key.rawValue)
         return true
      }

      return false
   }

   func loadValue<T: Decodable>(forKey key: UserDefaultsKeys) -> T? {
      guard
         let data = UserDefaults.standard.data(forKey: key.rawValue),
         let decoded = T(data)
      else {
         return nil
      }

      return decoded
   }

   func saveString(_ value: String, forKey key: UserDefaultsKeys) {
      set(value, forKey: key.rawValue)
      synchronize()
   }

   func clearForKey(_ key: UserDefaultsKeys) {
      set(nil, forKey: key.rawValue)
   }

   func loadString(forKey key: UserDefaultsKeys) -> String? {
      string(forKey: key.rawValue)
   }
}

extension UserDefaults {
   func saveValue<T>(_ value: T, forKey key: any Hashable) -> Bool where T : Decodable, T : Encodable {
      let encoder = JSONEncoder()
      if let encoded = try? encoder.encode(value) {
         let key = key.caseName
         UserDefaults.standard.set(encoded, forKey: key)
         return true
      }

      return false
   }

   func loadValue<T>(forKey key: any Hashable) -> T? where T : Decodable {
      let key = key.caseName
      guard
         let data = UserDefaults.standard.data(forKey: key),
         let decoded = T(data)
      else {
         return nil
      }

      return decoded
   }

   func clearForKey(_ key: any Hashable) {
      set(nil, forKey: key.caseName)
   }

}
