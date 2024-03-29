//
//  SpasibkaTests.swift
//  SpasibkaTests
//
//  Created by Aleksandr Solovyev on 17.06.2022.
//

import StackNinja
import SwiftUI
@testable import Spasibka
import XCTest

class WorksTests2: XCTestCase {
   private let retainer = Retainer()

   let works = TransactWorks<MockAsset>()

   var failWork: Work<String, String> { Work<String, String> {
      $0.fail($0.input)
   }}

   var stringWork: Work<String, String> { Work<String, String> { work in
      work.success(result: work.unsafeInput)
   }}

   var stringWork2: Work<String, String> { Work<String, String> { work in
      work.success(result: work.unsafeInput)
   }}

   enum Res {
      case fail
      case success
      case loadSuccess

      case recovered
      case recoverfailed

      case mapped
      case none

      case failworkSucces
      case failworkError

      case inputagain

      case stringworksuccess
      case stringworkerror
   }

   func testSaveLoadWork() {
      var result = Res.none
      var resultString = ""
      let exp = expectation(description: "1")

      stringWork
         .retainBy(retainer)
         .doAsync("Hello")
         .doSaveResult()
         .doInput("Again")
         .doNext(stringWork2)
         .onSuccess {
            result = .inputagain
            resultString = $0
            //  exp.fulfill()
            print(terminator: Array(repeating: "\n", count: 5).joined())
            log("Again")
         }
         .doLoadResult()
         .onSuccess { (text: String) in
            result = .loadSuccess
            resultString = text
            exp.fulfill()
            print(terminator: Array(repeating: "\n", count: 5).joined())
            log("Hello")
         }

      wait(for: [exp], timeout: 1)
      XCTAssertEqual(result, .loadSuccess)
      XCTAssertEqual(resultString, "Hello")
   }

   func testTransactInputScenario() {
      var result = Res.none
      var resultString = ""
      let exp = expectation(description: "1")

      works.coinInputParsing
         .doAsync("A")
         .onFail { (text: String) in
//            self?.works.updateAmount
//               .doAsync((text, false))
//               .onSuccess(slf?.setState) {
//                  .coinInputSuccess(text, false)
//               }
            result = .fail
         }
         .doAnyway()
         .doSaveResult() // save inputString
         .doMap {
            result = .mapped
            return ($0, true)
         }
         .doNext(works.updateAmount)
         .doNext(works.isCorrectBothInputs)
         .onSuccess {
            log("success")
         }
         .onFail {
            log("fail")
         }
         .onSuccessMixSaved({}) { (correct: Void, text: String) in
            exp.fulfill()
            resultString = text
            result = .success
         }
         .onFailMixSaved({}) { (correct: Void, text: String) in
            exp.fulfill()
            resultString = text
            result = .fail
         }

      wait(for: [exp], timeout: 1)
      XCTAssertEqual(result, .fail)
      XCTAssertEqual(resultString, "A")
   }
}
