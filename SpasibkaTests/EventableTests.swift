//
//  EventableTests.swift
//  SpasibkaTests
//
//  Created by Aleksandr Solovyev on 01.09.2022.
//

import StackNinja
@testable import Spasibka
import XCTest

struct TestEvents: InitProtocol {
   var stringValue: String?
   var voidValue: Void?
   var stringValue2: String?
}

class TestEventable: Eventable {
   typealias Events = TestEvents

   var events: [Int: LambdaProtocol?] = [:]
}

class EventableTests: XCTestCase {
   let testModel = TestEventable()

   func testExample() throws {

      let exp = expectation(description: "1")

      testModel.on(\.stringValue) { value in
         print(value)

      }

      XCTAssertEqual(testModel.events.count, 1)

      testModel.on(\.stringValue2) { value in
         print(value)

      }

      XCTAssertEqual(testModel.events.count, 2)

      testModel.on(\.voidValue) {
         exp.fulfill()
         
      }

      XCTAssertEqual(testModel.events.count, 3)

      testModel.send(\.stringValue, "1")
      testModel.send(\.stringValue2, "2")
      testModel.send(\.voidValue, ())

      wait(for: [exp], timeout: 1)
      // This is an example of a functional test case.
      // Use XCTAssert and related functions to verify your tests produce the correct results.
      // Any test you write for XCTest can be annotated as throws and async.
      // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
      // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
   }
}
