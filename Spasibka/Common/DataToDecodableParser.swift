//
//  DataToDecodableParser.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 09.08.2022.
//

import Foundation

struct DataToDecodableParser {
   func parse<T: Decodable>(_ data: Data) -> T? {
      let decoder = JSONDecoder()

      do {
         let result = try decoder.decode(T.self, from: data)
         return result
      } catch {
         print("Decode Pardsing Error: \(error)")
         return nil
      }
   }
}

extension Decodable {
   init?(_ data: Data?) {
      let parser = DataToDecodableParser()
      guard let data, let value: Self = parser.parse(data) else { return nil }

      self = value
   }
}

extension Encodable {
   var jsonData: Data? {
      try? JSONEncoder().encode(self)
   }
}

extension Encodable {
   var dictionary: [String: Any]? {
      guard let data = try? JSONEncoder().encode(self) else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
   }
}
