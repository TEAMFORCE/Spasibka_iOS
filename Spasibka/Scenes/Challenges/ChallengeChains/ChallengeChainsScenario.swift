//
//  ChallengeChainsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.09.2023.
//

import StackNinja

struct ChallengeChainsScenarioEvents: ScenarioEvents {
   let completedChains: Out<Void>
   let presentActiveChallenges: Out<Void>
   let presentDeferredChallenges: Out<Void>

   let didSelectChallengeIndex: Out<Int>

   let createChallenge: VoidWork
   let reloadChallenges: VoidWork

   let requestPagination: VoidWork
}

final class ChallengeChainsScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<ChallengeChainsScenarioEvents, ChallengeChainsState, ChallengeChainsWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()

      start
         .doNext(works.loadUserDataToStore)
         .doSendEvent(events.requestPagination)

      events.completedChains
         .onSuccess(setState, .loading)
         .doNext(works.setCurrentFilterCompleted)
         .doSendEvent(events.requestPagination)

      events.presentActiveChallenges
         .onSuccess(setState, .loading)
         .doNext(works.setCurrentFilterActive)
         .doSendEvent(events.requestPagination)

      events.presentDeferredChallenges
         .onSuccess(setState, .loading)
         .doNext(works.setCurrentFilterDeferred)
         .doSendEvent(events.requestPagination)

      events.didSelectChallengeIndex
         .doNext(works.getPresentedChallengeByIndex)
         .doSaveResult()
         .doInput(())
         .doNext(works.getProfileId)
         .onSuccessMixSaved(setState) { .presentChainDetails(($1, $0)) }

      events.createChallenge
         .onSuccess(setState, .presentCreateChallenge)

      events.reloadChallenges
         .onSuccess(setState, .loading)
         .doSendEvent(events.requestPagination)

      events.requestPagination
         .doNext(works.loadChallengesForCurrentFilter)
         .onFail(setState) { .error }
         .doNext(IsNotEmpty())
         .onSuccess(setState) { .presentChallenges($0) }
         .onFail(setState, .hereIsEmpty)
   }
}
