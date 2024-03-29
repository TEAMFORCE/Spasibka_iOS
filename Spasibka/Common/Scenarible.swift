//
//  Scenario.swift
//  TeamForce
//
//  Created by Aleksandr Solovyev on 16.08.2022.
//

import ReactiveWorks

protocol Scenarible: AnyObject {
   var scenario: Scenario { get }
}

protocol Scenarible2: Scenarible {
   var scenario2: Scenario { get }
}

protocol Scenarible3: Scenarible2 {
   var scenario3: Scenario { get }
}

// MARK: - Scenario protocol and base scenario

protocol Scenario {
   func start()
}

protocol ScenarioParams {
   associatedtype Asset: AssetRoot
   associatedtype ScenarioInputEvents: Any
   associatedtype ScenarioModelState: Any
   associatedtype ScenarioWorks: Any
}

class BaseParamsScenario<Params: ScenarioParams>: BaseScenario<
   Params.ScenarioInputEvents,
   Params.ScenarioModelState,
   Params.ScenarioWorks
> {}

class BaseScenario<Events, State, Works>: Scenario {
   var works: Works
   var events: Events

   var setState: (State) -> Void = { _ in
      assertionFailure("stateDelegate (setState:) did not injected into Scenario")
   }

   required init(works: Works, stateDelegate: ((State) -> Void)?, events: Events) {
      self.events = events
      self.works = works
      if let setStateFunc = stateDelegate {
         setState = setStateFunc
      }
   }

   open func start() {}
}
