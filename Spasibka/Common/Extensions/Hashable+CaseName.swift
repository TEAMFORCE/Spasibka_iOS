//
//  Hashable+CaseName.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.09.2023.
//

import Foundation

protocol CaseName {
   var caseName: String { get }
}

extension Hashable {
   var caseName: String {
      return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
   }

   func hash(into hasher: inout Hasher) {
      hasher.combine(caseName)
   }
}

extension Hashable {
   static func == (lhs: Self, rhs: Self) -> Bool {
      return lhs.hashValue == rhs.hashValue
   }
}

protocol AssociatedValueProtocol: Hashable {
   func associatedValue() -> Codable?
}

extension AssociatedValueProtocol {
   func valueAsT<T>(_ value: Codable) -> T? {
      value as? T
   }
}



