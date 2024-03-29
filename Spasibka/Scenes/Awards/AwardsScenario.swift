//
//  AwardsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.12.2023.
//

import StackNinja

struct AwardsEvents: ScenarioEvents {
   let didSegmentButtonPressed: Out<Button2Event>
}

final class AwardsScenario<Asset: ASP>: BaseWorkableScenario<AwardsEvents, AwardsState, AwardsWorks<Asset>> {
   override func configure() {
      super.configure()

      start
         .onSuccess(setState, .allAwards)

      events.didSegmentButtonPressed
         .onSuccess { [weak self] in
            switch $0 {
            case .didTapButton1:
               self?.setState(.allAwards)
            case .didTapButton2:
               self?.setState(.myAwards)
            }
         }
   }
}
