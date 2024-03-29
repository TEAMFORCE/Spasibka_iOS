//
//  PluralCurrencyManager.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.06.2023.
//

import Foundation

final class PluralCurrencyManager {
   func pluralCurrency(sum: Int, case: Cases) -> String {
      pluralCurrency(sum: sum, case: `case`, forms: pluralCurrencyFormsForCurrentLocale)
   }

   func pluralCurrencyForForm(_ form: PluralForms.CaseForms) -> String {
      pluralCurrencyFormsForCurrentLocale.forms[form] ?? ""
   }

   func updatePluralForms(_ forms: [String: PluralForms]?) {
      pluralCurrencyForms = forms
   }

   private var pluralCurrencyForms: [String: PluralForms]?

   private let defaultPluralForms =
   [
      "RU": PluralForms([
         .form1: "спасибка",
         .form2: "спасибке",
         .form3: "спасибку",
         .form4: "спасибок",
         .form5: "спасибки",
      ]),
      "EN": PluralForms([
         .form1: "thanks",
         .form2: "thanks",
         .form3: "thanks",
         .form4: "thanks",
         .form5: "thanks",
      ]),
   ]

   private var pluralCurrencyFormsForCurrentLocale: PluralForms {
      guard let lang = Locale
         .current
         .languageCode?
         .uppercased()
      else { return defaultPluralForms["RU"]! }

      return pluralCurrencyForms?[lang] ?? defaultPluralForms[lang] ?? defaultPluralForms["RU"]!
   }

   private func pluralCurrency(sum: Int, case: Cases, forms: PluralForms) -> String {
      let lastDigit = sum % 10
      let lastTwoDigits = sum % 100
      let forms = forms.forms

      if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
         return forms[.form4] ?? ""
      } else if lastDigit == 1 {
         switch `case` {
         case .genitive:
            return forms[.form1] ?? ""
         case .accusative:
            return forms[.form3] ?? ""
         case .dative:
            return forms[.form2] ?? ""
         }
      } else if lastDigit >= 2 && lastDigit <= 4 {
         return forms[.form5] ?? ""
      } else if (lastDigit >= 5 && lastDigit <= 9) || lastDigit == 0 {
         return forms[.form4] ?? ""
      } else {
         return forms[.form5] ?? ""
      }
   }
}

enum Cases {
   case genitive
   case accusative
   case dative
}

