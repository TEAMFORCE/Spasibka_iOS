//
//  Array+Safe.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import Foundation

extension Array {
   subscript(safe index: Int) -> Element? {
      return indices ~= index ? self[index] : nil
   }
}
