//
//  MemoryLeakTests.swift
//  SpasibkaTests
//
//  Created by Aleksandr Solovyev on 18.08.2022.
//

@testable import StackNinja
@testable import Spasibka
import XCTest

//class HistoryMemoryLeakTests: XCTestCase {
//   private var viewModels = HistoryViewModels<ProductionAsset.Design>()
//
//   func testSceneMemoryLeaks() throws {
//      var scene: HistoryScene? = HistoryScene<ProductionAsset>()
//
//      weak var weakScene = scene
//      weak var weakView: UIView? = scene?.uiView
//      weak var weakWorks = weakScene?.scenario.works
//
//      scene = nil
//
//      XCTAssertNil(weakScene)
//      XCTAssertNil(weakView)
//      XCTAssertNil(weakWorks)
//   }
//
//   func testWorksMemoryLeaks() throws {
//      var works: HistoryWorks<ProductionAsset>? = HistoryWorks<ProductionAsset>()
//
//      weak var weakWorks = works
//      works = nil
//
//      XCTAssertNil(weakWorks)
//   }
//
//   func testScenarioMemoryLeaks() throws {
//      let works = HistoryWorks<ProductionAsset>()
//      var scenario: HistoryScenario? = HistoryScenario(
//         works: works,
//         events: HistoryScenarioEvents(
//            segmentContorlEvent: viewModels.segmentedControl.onEvent(\.segmentChanged)
//         )
//      )
//
//      weak var weakScenario = scenario
//      scenario = nil
//
//      XCTAssertNil(weakScenario)
//   }
//}
//
//class TransactMemoryLeakTests: XCTestCase {
//   private var viewModels = TransactViewModels<ProductionAsset>()
//
//   func testSceneMemoryLeaks() throws {
//      var scene: TransactScene? = TransactScene<ProductionAsset>()
//
//      weak var weakScene = scene
//      weak var weakView: UIView? = scene?.uiView
//      weak var weakWorks = weakScene?.scenario.works
//
//      scene = nil
//
//      XCTAssertNil(weakScene)
//      XCTAssertNil(weakView)
//      XCTAssertNil(weakWorks)
//   }
//
//   func testViewMemoryLeaks() throws {
//      var scene: TransactScene? = TransactScene<ProductionAsset>()
//      weak var view: UIView? = scene?.uiView
//
//      scene = nil
//
//      XCTAssertNil(view)
//   }
//
//   func testWorksMemoryLeaks() throws {
//      var works: TransactWorks<ProductionAsset>? = TransactWorks<ProductionAsset>()
//
//      weak var weakWorks = works
//      works = nil
//
//      XCTAssertNil(weakWorks)
//   }
//
//   func testScenarioMemoryLeaks() throws {
//      var scenario: TransactScenario? = TransactScenario(
//         works: TransactWorks<ProductionAsset>(),
//         events: TransactScenarioEvents(
//            userSearchTXTFLDBeginEditing: viewModels.userSearchTextField.onEvent(\.didBeginEditing),
//            userSearchTFDidEditingChanged: viewModels.userSearchTextField.onEvent(\.didEditingChanged),
//            userSelected: viewModels.tableModel.onEvent(\.didSelectRow),
//            sendButtonEvent: viewModels.sendButton.on(\.didTap),
//            transactInputChanged: viewModels.transactInputViewModel.textField.onEvent(\.didEditingChanged),
//            reasonInputChanged: viewModels.reasonTextView.onEvent(\.didEditingChanged)
//         )
//      )
//
//      weak var weakScenario = scenario
//      weak var weakWorks = weakScenario?.works
//      scenario = nil
//
//      XCTAssertNil(weakScenario)
//      XCTAssertNil(weakWorks)
//   }
//
//   func testModelMemoryLeak() {
//      var stack: StackModel? = StackModel()
//      weak var view = stack?.uiView
//
//      stack = nil
//
//      XCTAssertNil(view)
//   }
//}
