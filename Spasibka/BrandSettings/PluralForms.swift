//
//  DeclineCurrency.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.06.2023.
//

import Foundation

struct PluralForms: Codable {
   enum CaseForms: String, CodingKey {
      case form1
      case form2
      case form3
      case form4
      case form5
   }

   let forms: [CaseForms: String]

   init(_ forms: [CaseForms: String]) {
      self.forms = forms
   }

   init(from decoder: Decoder) throws {
      if let container = try? decoder.container(keyedBy: CaseForms.self) {
         var forms: [CaseForms: String] = [:]
         
         for key in container.allKeys {
            let value = try container.decode(String.self, forKey: key)
            forms[key] = value
         }
         
         self.forms = forms
      } else {
         self.forms = [:]
      }
   }

   func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CaseForms.self)

      for (key, value) in forms {
         try container.encode(value, forKey: key)
      }
   }
}
