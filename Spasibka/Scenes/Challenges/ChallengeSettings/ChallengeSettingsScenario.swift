//
//  ChallengeSettingsScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.12.2022.
//

import StackNinja
import Foundation

struct ChallengeSettingsScenarioEvents : ScenarioEvents {   
   let saveInput: Out<ChallengeSettings>
   let severalReportsTurnOn: Out<Void>
   let severalReportsTurnOff: Out<Void>
   let showCandidatesTurnOn: Out<Void>
   let showCandidatesTurnOff: Out<Void>

   let didSelectChallengeTypeIndex: Out<Int>

   let closeButtonTapped: Out<Void>

}

final class ChallengeSettingsScenario<Asset: AssetProtocol>: BaseWorkableScenario<ChallengeSettingsScenarioEvents, ChallengeSettingsSceneState, ChallengeSettingsWorks<Asset>> {
   override func configure() {
      super.configure()
      
      events.saveInput
         .doNext(works.saveInput)
         .onSuccess(setState) { .setInputValues($0) }
      
      events.showCandidatesTurnOn
         .doNext(works.showCandidatesTurnOn)
      
      events.showCandidatesTurnOff
         .doNext(works.showCandidatesTurnOff)
      
      events.severalReportsTurnOn
         .doNext(works.severalReportsTurnOn)
      
      events.severalReportsTurnOff
         .doNext(works.severalReportsTurnOff)

      events.didSelectChallengeTypeIndex
         .doNext(works.changeChallengeTypeIndex)
         .onSuccess(setState) { .updateChallengeType($0) }

      events.closeButtonTapped
         .doNext(works.getCurrentSettings)
         .onSuccess(setState, .cancelButtonPressed)
   }
}
