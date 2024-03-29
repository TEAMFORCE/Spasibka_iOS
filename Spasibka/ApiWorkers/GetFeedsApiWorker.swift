//
//  GetFeedsApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.08.2022.
//

import Foundation

struct FeedTag: Codable {
   let id: Int
   let name: String

   enum CodingKeys: String, CodingKey {
      case id = "tag_id"
      case name
   }
}
