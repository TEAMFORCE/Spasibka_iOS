//
//  Onboarding2Scenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import StackNinja

final class Onboarding2Scenario<Asset: ASP>: BaseScenarioExtended<Onboarding2<Asset>> {
   override func configure() {
      super.configure()

//      events.didTapConfigModeButton
//         .doNext(works.changeConfigMode)
//         .onSuccess(setState) { .configMode(automatic: $0) }

      events.didTapStartButton
         .onSuccess(setState, .loading)
         .doNext(works.updateCommunityPeriod)
         .onFail(setState, .loadingError)
         .doNext(works.loadInviteLink)
         .onFail(setState, .loadingError)
         .onSuccess(setState) { .routeToFinishOnboarding(inviteLink: $0) }
         .onFail(setState, .loadingError)
   }
}
