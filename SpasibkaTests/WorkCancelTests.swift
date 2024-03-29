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

class WorkCancelTests: XCTestCase {
   private let retainer = Retainer()

   var workA: Work<String, String> { Work<String, String> { work in
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
         work.success(result: work.unsafeInput)
      }
   }}

   var workNextA: Work<String, String> { Work<String, String> { work in
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
         work.success(result: work.unsafeInput)
      }
   }}

   var workB: Work<String, String> { Work<String, String> { work in
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
         work.success(result: work.unsafeInput)
      }
   }}

   func testWorkCancel() {
      var result: String = ""

      let exp = expectation(description: "1")

      let workA = self.workA
         .retainBy(retainer)
         .doAsync("a")
         .onSuccess {
            print("a", terminator: "-")
            result = $0
            exp.fulfill()
         }

      workB
         .retainBy(retainer)
         .doCancel(workA)
         .doAsync("b")
         .onSuccess {
            print("b", terminator: "-")
            result = $0

            workA
               .doAsync("c")
               .onSuccess {
                  result = $0
                  print("c", terminator: "-")
                  exp.fulfill()
               }
         }

      workA.doAsync("c")

      wait(for: [exp], timeout: 100)
      XCTAssertEqual(result, "c")
   }

   func testChainWorkCancel() {
      var result: String = ""

      let exp = expectation(description: "2")

      let workA = self.workA
         .retainBy(retainer)
         .doAsync("a")
         .doNext(workNextA)
         .onSuccess {
            print("nextA", terminator: "-")
            result = "nextA"
            exp.fulfill()
         }

      workB
         .retainBy(retainer)
         .doCancel(workA)
         .doAsync("b")
         .onSuccess {
            print("b", terminator: "-")
            result = $0

            workA
               .doAsync()
         }

      workA.doAsync("c")

      wait(for: [exp], timeout: 100)
      XCTAssertEqual(result, "nextA")
   }
}
