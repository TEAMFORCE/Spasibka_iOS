//
//  PayloadedScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

protocol PayloadedScenaribleModelProtocol: Assetable, PayloadedScenarible, StateMachine {}

protocol ScenarioPayloadedEvents: ScenarioEvents {
   associatedtype Payload
   var payload: Out<Payload> { get }
}

protocol PayloadedScenario: Scenario {
   associatedtype ScenarioInputEvents: ScenarioPayloadedEvents
   var events: ScenarioInputEvents { get }
}

protocol PayloadedScenarible: Scenarible where Scenery: PayloadedScenario {
   typealias Payload = Scenery.ScenarioInputEvents.Payload
   var scenario: Scenery { get }
}

extension PayloadedScenarible {
   func startWithPayloadWork(_ payloadWork: Out<Scenery.ScenarioInputEvents.Payload>) {
      payloadWork
         .onSuccess(self) {
            $0.startWithPayload($1)
         }
   }

   func startWithPayload(_ payload: Scenery.ScenarioInputEvents.Payload) {
      scenario.events.payload.sendAsyncEvent(payload)
      scenario.configureAndStart()
   }
   
   func startWithGenericPayload<T>(_ payload: T) {
      guard let payload = payload as? Payload else {
         return
      }
      
      scenario.events.payload.sendAsyncEvent(payload)
      scenario.configureAndStart()
   }
}

class BasePayloadedScenario<
   Events: ScenarioPayloadedEvents,
   State,
   Works: PayloadWorksProtocol
>:
   BaseWorkableScenario<Events, State, Works>, PayloadedScenario
   where Events.Payload == Works.Store.Payload
{
   override func configure() {
      super.configure()

      events.payload
         .doNext(works.storePayload)
   }
}
