//
//  Balance.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import Foundation

struct Balance: Decodable {
   let income: Income
   let distr: Distr
}

struct Income: Decodable {
   let amount: Int
   let frozen: Int
   let sent: Int
   let received: Int
   let cancelled: Int
}

struct Distr: Codable {
   let amount: Int
   let expireDate: String?
   let frozen: Int
   let sent: Int
   let received: Int
   let cancelled: Int

   enum CodingKeys: String, CodingKey {
      case amount
      case expireDate = "expire_date"
      case frozen
      case sent
      case received
      case cancelled
   }
}
