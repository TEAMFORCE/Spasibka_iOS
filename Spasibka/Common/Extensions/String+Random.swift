//
//  String+Random.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.08.2022.
//

import Foundation

extension String {
   static func randomInt(_ max: Int) -> String {
      String(Int.random(in: 0 ... max))
   }

   static var randomUrlImage: String {
      "https://picsum.photos/200"
   }

   static func random(_ max: Int) -> String {
      let count = Int.random(in: 0 ... max)

      let letters = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      let randomString = (0 ..< count).map { _ in
         String(letters.randomElement()!)
      }
      .joined()
      return randomString
   }
}
