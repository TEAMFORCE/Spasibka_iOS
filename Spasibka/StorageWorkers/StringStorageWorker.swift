//
//  StringStorageModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.07.2022.
//

import Foundation
import StackNinja

final class StringStorageWorker: BaseModel {
   private var storageEngine: StringStorageProtocol?

   convenience init(engine: StringStorageProtocol) {
      self.init()

      storageEngine = engine
   }
}

extension StringStorageWorker: WorkerProtocol {
   func doAsync(work: Work<String, String>) {
      guard
         let input = work.input,
         let value = storageEngine?.load(forKey: input)
      else {
         print("\nNo value for key: \(String(describing: work.input))\n")

         work.fail()
         return
      }

      work.success(result: value)
   }
}

extension StringStorageWorker: Stateable {
   enum State {
      case clearForKey(String)
      case save((value: String, key: String))
   }

   func applyState(_ state: State) {
      switch state {
      case .save(let keyValue):
         storageEngine?.save(keyValue.value, forKey: keyValue.key)
      case .clearForKey(let key):
         storageEngine?.clearForKey(key)
      }
   }
}

// MARK: - StringStorageProtocol---

protocol StringStorageProtocol {
   func save(_ value: String, forKey key: String)
   func load(forKey key: String) -> String?
   func clearForKey(_ key: String)
}

import SwiftKeychainWrapper

struct KeyChainStore: StringStorageProtocol {
   func save(_ value: String, forKey key: String) {
      KeychainWrapper.standard.set(value, forKey: key)
   }

   func load(forKey key: String) -> String? {
      KeychainWrapper.standard.string(forKey: key)
   }
   
   func clearForKey(_ key: String) {
      KeychainWrapper.standard.removeObject(forKey: key)
   }
}

struct MockKeyChainStore: StringStorageProtocol {
   func save(_ value: String, forKey key: String) {}

   func load(forKey key: String) -> String? {
      Config.tokenKey
   }
   
   func clearForKey(_ key: String) {
      KeychainWrapper.standard.removeObject(forKey: key)
   }
}
