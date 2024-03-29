//
//  ChallengeGroupScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.09.2023.
//

import StackNinja

struct ChallengeGroupScenarioInputEvents: ScenarioEvents {
   let didTabSettings: Out<Void>
   let didTapAllChallenges: Out<Void>
   let didTapAllChallengeChains: Out<Void>
}

final class ChallengeGroupScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<ChallengeGroupScenarioInputEvents, ChallengeGroupState, ChallengeGroupWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()


      events.didTapAllChallenges
         .onSuccess(setState, .presentAllChallenges)

      events.didTapAllChallengeChains
         .onSuccess(setState, .presentAllChallengeChains)
//      events.didSegmentButtonPressed
//         .onSuccess { [weak self] in
//            switch $0 {
//            case .didTapButton1:
//               self?.setState(.presentChallenges)
//            case .didTapButton2:
//               self?.setState(.presentChallengeChains)
//            case .didTapButton3:
//               self?.setState(.presentTemplates)
//            }
//         }
   }
}

