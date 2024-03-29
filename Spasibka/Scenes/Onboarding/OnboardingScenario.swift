//
//  OnboardingScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import StackNinja

final class OnboardingScenario<Asset: ASP>: BaseScenarioExtended<Onboarding<Asset>> {
   override func configure() {
      super.configure()

      events.input
         .doNext(works.setUserName)

      events.didTapCreateCommunity
         .onSuccess(setState, .presentCreateCommunityPopup)

      events.didTapJoinCommunity
         .onSuccess(setState, .presentJoinCommunityPopup)

      events.didTapCancelPopups
         .onSuccess(setState, .hidePopups)

      events.didEditingCreateCommunityTitle
         .doNext(TrimLeadingWhitespacesWorker())
         .doSaveResult()
         .doNext(StringValidateWorker(isEmptyValid: false, minSymbols: 3))
         .onSuccessMixSaved(setState) {
            .createCommunityPopupState(buttonEnabled: true, text: $1)
         }
         .onFailMixSaved(setState) {
            .createCommunityPopupState(buttonEnabled: false, text: $1)
         }
         .doLoadResult()
         .doNext(works.updateCreateCommunityName)

      events.didEditingJoinCommunitySharedKey
         .doNext(TrimLeadingWhitespacesWorker())
         .doSaveResult()
         .doNext(StringValidateWorker(isEmptyValid: false, minSymbols: 3))
         .onSuccessMixSaved(setState) {
            .joinCommunityPopupState(buttonEnabled: true, text: $1)
         }
         .onFailMixSaved(setState) {
            .joinCommunityPopupState(buttonEnabled: false, text: $1)
         }
         .doLoadResult()
         .doNext(works.updateJoinCommunitySharedKey)

      events.didTapContinueCreateCommunity
         .onSuccess(setState, .loading)
         .doNext(works.getCommunityName)
         .doNext(works.createCommunityWithTitle)
         .onSuccess(setState, .loadingSuccess)
         .onFail(setState, .loadingError)
         .doVoidNext(works.getCommunityName)
         .onSuccess(setState) { .routeToConfigureCommunityWithName($0) }

      events.didTapContinueJoinCommunity
         .doNext(works.getUserName)
         .doSaveResult()
         .doVoidNext(works.getSharedKey)
         .onSuccessMixSaved {
            Asset.router?.route(
               .push, scene: \.login, payload: .init(sharedKey: $0, userName: $1)
            )
         }
   }
}
