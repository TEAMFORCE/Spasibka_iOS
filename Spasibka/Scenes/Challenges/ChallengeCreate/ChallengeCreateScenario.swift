//
//  ChallengeCreateScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 11.10.2022.
//

import Foundation
import StackNinja

struct ChallengeCreateScenarioEvents: ScenarioEvents {
   let payload: Out<ChallengeCreateInput>
   let didTitleInputChanged: Out<String>
   let didDescriptionInputChanged: Out<String>
   let didPrizeFundChanged: Out<String>

   let didStartDatePicked: Out<Date>
   let didStartDateCleared: VoidWork
   let didFinishDatePicked: Out<Date>
   let didFinishDateCleared: VoidWork

   let didSendPressed: VoidWork

   let didPrizePlaceInputChanged: Out<String>

   let openSettingsScene: Out<Void>
   
   let didTapDelete: VoidWork
   
   let didSelectFondAccountIndex: Out<Int>
   
   let delayedStartChanged: Out<Bool>
   let balanceAccountHide: Out<Bool>
   
   // images
   let didDeleteImageAtIndex: Out<Int>
   let didMoveImage: Out<(from: Int, to: Int)>
}

final class ChallengeCreateScenario<Asset: AssetProtocol>: BaseWorkableScenario<ChallengeCreateScenarioEvents, ChallengeCreateSceneState, ChallengeCreateWorks<Asset>> {
   override func configure() {
      super.configure()

      events.payload
         .doSaveResult()
         .doVoidNext(works.loadCreateChallengeSettings)
         .onFail(setState, .errorState)
         .doVoidNext(works.getSavedSettings)
         .onSuccess(setState) { .setFondAccountValues($0) }
         .doLoadResult()
         .doNext(works.saveTemplateValues)
         .onSuccess { [weak self] (result: ChallengeCreateInput) in
            guard let stateFunc = self?.setState else { return }
            switch result {
            case .createChallenge:
               stateFunc(.initCreateChallenge)
            case let .createChallengeWithTemplate(value):
               stateFunc(.initCreateChallengeWithTemplate(value))
            case let .editChallenge(value):
               stateFunc(.initEditChallenge(value))
            }
         }
         .onSuccess(setState, .readyToInput)
         .doVoidNext(works.checkAllReady)
         .onSuccess(setState) { .setReady($0) }

      events.didTitleInputChanged
         .doNext(works.titleCacher)
         .doNext(works.setTitle)
         .onSuccess(setState) { .updateTitleTextField($0) }
         .doVoidNext(works.checkAllReady)
         .onSuccess(setState) { .setReady($0) }

      events.didDescriptionInputChanged
         .doNext(works.descriptCacher)
         .doNext(works.setDesription)
         .onSuccess(setState) { .updateDescriptTextField($0) }
         .doVoidNext(works.checkAllReady)
         .onSuccess(setState) { .setReady($0) }

      events.didPrizeFundChanged
         .doNext(works.setPrizeFund)
         .doNext(works.checkAllReady)
         .onSuccess(setState) { .setReady($0) }

      events.didPrizePlaceInputChanged
         .doNext(works.setPrizePlace)
         .doNext(works.checkAllReady)
         .onSuccess(setState) { .setReady($0) }

      events.didSendPressed
         .onSuccess(setState, .awaitingState)
         .doNext(works.createChallenge)
         .onSuccess(setState, .challengeCreated)
         .onFail(setState, .errorState)

      events.didStartDatePicked
         .doNext(works.setStartDate)
      
      events.didStartDateCleared
         .doNext(works.clearStartDate)

      events.didFinishDatePicked
         .doNext(works.setFinishDate)

      events.didFinishDateCleared
         .doNext(works.clearFinishDate)

      events.openSettingsScene
         .doNext(works.getSavedSettings)
         .onSuccess(setState) { .presentSettingsScene($0) }
      
      events.didTapDelete
         .doNext(works.deleteChallenge)
         .onSuccess(setState, .challengeDeleted)
         .onFail(setState, .errorState)
      
      events.didSelectFondAccountIndex
         .doNext(works.changeBalanceTypeIndex)
      
      events.delayedStartChanged
         .doNext(works.hideStartDate)
         .onSuccess(setState) { .updateDelayedStart($0) }
      
      events.balanceAccountHide
         .doNext(works.hideBalanceAccount)
         .onSuccess(setState) { .hideBalanceAccount($0) }
      
   }
}
