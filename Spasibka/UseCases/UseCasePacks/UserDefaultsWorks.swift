//
//  UserDefaultsUseCases.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.01.2023.
//

import StackNinja

enum UserDefaultsValue {
   case currentUser(UserData?)
   case currentOrganizationID(Int?)
   case appLanguage(String?)
}

extension UserDefaultsValue: AssociatedValueProtocol {
   func associatedValue<T>() -> T? {
      switch self {
      case .currentUser(let value):
         return valueAsT(value)
      case .currentOrganizationID(let value):
         return valueAsT(value)
      case .appLanguage(let value):
         return valueAsT(value)
      }
   }
}

struct UserDefaultsData<T: Codable> {
   let value: T
   let key: UserDefaultsKeys
}

struct UserDefaultsWorks<Asset: ASP>: WorkBasket {
   let retainer = Retainer()

   func saveValueWork<T: Codable>() -> Work<UserDefaultsData<T>, Void> {
      .init {
         let key = $0.unsafeInput.key
         let value = $0.unsafeInput.value

         if userDefaults.saveValue(value, forKey: key) {
            $0.success()
         } else {
            $0.fail()
         }
      }.retainBy(retainer)
   }

   func loadValueWork<T: Codable>() -> Work<UserDefaultsKeys, T> { .init {
      guard let result: T = userDefaults.loadValue(forKey: $0.unsafeInput) else {
         $0.fail()
         return
      }

      $0.success(result)
   }.retainBy(retainer) }

   var clearForKeyWork: Work<UserDefaultsKeys, Void> { .init {
      userDefaults.clearForKey($0.unsafeInput)

      $0.success()
   }.retainBy(retainer) }
}

extension UserDefaultsWorks {
   var saveAssociatedValueWork: In<any AssociatedValueProtocol> { .init { work in
      guard
         let value = work.in.associatedValue()
      else {
         work.fail()
         return
      }

      let key = work.in.caseName
      userDefaults.saveValue(value, forKey: key)

      work.success()
   }.retainBy(retainer) }

   func loadAssociatedValueWork<T: Codable>() -> In<any AssociatedValueProtocol>.Out<T> { .init { work in
      guard
         let result: T = userDefaults.loadValue(forKey: work.in)
      else {
         work.fail()
         return
      }

      work.success(result)
   }.retainBy(retainer) }

   var clearAssociatedValueWork: In<any AssociatedValueProtocol> { .init { work in
      let key = work.in.caseName

      userDefaults.clearForKey(key)
      work.success()
   }.retainBy(retainer) }
}

private extension UserDefaultsWorks {
   var userDefaults: UserDefaultsStorageProtocol { Asset.service.userDefaultsStorage }
}
