//
//  Queue.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 03.09.2022.
//

import Foundation

final class Queue<T> {
   private var arr: [T] = []

   func push(_ element: T) {
      arr.append(element)
   }

   func pop() -> T? {
      guard let first = arr.first else {
         return nil
      }

      arr.remove(at: 0)

      return first
   }

   var isEmpty: Bool {
      arr.isEmpty
   }
}
