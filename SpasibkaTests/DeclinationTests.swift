//
//  DeclinationTests.swift
//  SpasibkaTests
//
//  Created by Aleksandr Solovyev on 08.06.2023.
//

@testable import Spasibka
import XCTest

final class DeclinationTests: XCTestCase {
   let currencyForms = PluralForms([
      .form1: "спасибка",
      .form2: "спасибке",
      .form3: "спасибку",
      .form4: "спасибок",
      .form5: "спасибки"
   ])

   func testDeclineCurrency() {
      XCTAssertEqual(pluralCurrency(sum: 0, case: .genitive, forms: currencyForms), "спасибок")

      XCTAssertEqual(pluralCurrency(sum: 1, case: .genitive, forms: currencyForms), "спасибка")
      XCTAssertEqual(pluralCurrency(sum: 1, case: .accusative, forms: currencyForms), "спасибку")
      XCTAssertEqual(pluralCurrency(sum: 1, case: .dative, forms: currencyForms), "спасибке")

      XCTAssertEqual(pluralCurrency(sum: 2, case: .genitive, forms: currencyForms), "спасибки")
      XCTAssertEqual(pluralCurrency(sum: 3, case: .genitive, forms: currencyForms), "спасибки")
      XCTAssertEqual(pluralCurrency(sum: 4, case: .genitive, forms: currencyForms), "спасибки")
      XCTAssertEqual(pluralCurrency(sum: 5, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 6, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 7, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 8, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 9, case: .genitive, forms: currencyForms), "спасибок")

      XCTAssertEqual(pluralCurrency(sum: 10, case: .genitive, forms: currencyForms), "спасибок")

      XCTAssertEqual(pluralCurrency(sum: 11, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 11, case: .accusative, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 11, case: .dative, forms: currencyForms), "спасибок")

      XCTAssertEqual(pluralCurrency(sum: 12, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 13, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 14, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 15, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 16, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 17, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 18, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 19, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 20, case: .genitive, forms: currencyForms), "спасибок")

      XCTAssertEqual(pluralCurrency(sum: 21, case: .genitive, forms: currencyForms), "спасибка")
      XCTAssertEqual(pluralCurrency(sum: 21, case: .accusative, forms: currencyForms), "спасибку")
      XCTAssertEqual(pluralCurrency(sum: 21, case: .dative, forms: currencyForms), "спасибке")

      XCTAssertEqual(pluralCurrency(sum: 22, case: .genitive, forms: currencyForms), "спасибки")
      XCTAssertEqual(pluralCurrency(sum: 23, case: .genitive, forms: currencyForms), "спасибки")
      XCTAssertEqual(pluralCurrency(sum: 24, case: .genitive, forms: currencyForms), "спасибки")
      XCTAssertEqual(pluralCurrency(sum: 25, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 100, case: .genitive, forms: currencyForms), "спасибок")

      XCTAssertEqual(pluralCurrency(sum: 101, case: .genitive, forms: currencyForms), "спасибка")
      XCTAssertEqual(pluralCurrency(sum: 101, case: .accusative, forms: currencyForms), "спасибку")
      XCTAssertEqual(pluralCurrency(sum: 101, case: .dative, forms: currencyForms), "спасибке")

      XCTAssertEqual(pluralCurrency(sum: 102, case: .genitive, forms: currencyForms), "спасибки")
      XCTAssertEqual(pluralCurrency(sum: 103, case: .genitive, forms: currencyForms), "спасибки")
      XCTAssertEqual(pluralCurrency(sum: 104, case: .genitive, forms: currencyForms), "спасибки")
      XCTAssertEqual(pluralCurrency(sum: 105, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 1000, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 1011, case: .genitive, forms: currencyForms), "спасибок")
      XCTAssertEqual(pluralCurrency(sum: 1231, case: .genitive, forms: currencyForms), "спасибка")
      XCTAssertEqual(pluralCurrency(sum: 1333, case: .genitive, forms: currencyForms), "спасибки")
      XCTAssertEqual(pluralCurrency(sum: 1422, case: .genitive, forms: currencyForms), "спасибки")
   }
}
