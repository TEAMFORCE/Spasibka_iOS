//
//  SpasibkaTests.swift
//  SpasibkaTests
//
//  Created by Aleksandr Solovyev on 17.06.2022.
//

import StackNinja
@testable import Spasibka
import XCTest

class WorksTests: XCTestCase {
   func testSyncWork() {
      let work = Work<Int, Int>(input: 10) {
         $0.success(result: $0.unsafeInput + 1)
      }
      work.doSync()

      XCTAssertEqual(work.result, 11)
   }

   func testAsyncWork() {
      let exp = expectation(description: "")
      let work = Work<Int, Int>(input: 10) {
         $0.success(result: $0.unsafeInput + 1)
         exp.fulfill()
      }
      work.doAsync()

      wait(for: [exp], timeout: 1)

      XCTAssertEqual(work.result, 11)
   }

   func testWorkDoMixIsNotCatchObj() {
      var testObj: NSObject? = NSObject()
      weak var testObjCheck = testObj
      let exp = expectation(description: "")
      let work = Work<Int, Int>(input: 10) {
         $0.success(result: $0.unsafeInput + 1)
      }
      work
         .doWeakMix(testObj)
         .onSuccess { _, _ in
            fatalError()
         }.onFail {
            exp.fulfill()
         }
      testObj = nil
      work.doAsync()

      wait(for: [exp], timeout: 1)

      XCTAssertNil(testObjCheck)
   }

   func testWorkDoInputIsNotCatchObj() {
      var testObj: NSObject? = NSObject()
      weak var testObjCheck = testObj
      let exp = expectation(description: "")
      let work = Work<Int, Int>(input: 10) {
         $0.success(result: $0.unsafeInput + 1)
      }
      work
         .doWeakInput(testObj)
         .onSuccess { _ in
            fatalError()
         }.onFail {
            exp.fulfill()
         }
      testObj = nil
      work.doAsync()

      wait(for: [exp], timeout: 1)

      XCTAssertNil(testObjCheck)
   }
}
