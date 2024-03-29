//
//  ChallengesScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 06.10.2022.
//

import StackNinja

struct ChallengesScenarioInputEvents: ScenarioEvents {   
   let presentAllChallenges: Out<Void>
   let presentActiveChallenges: Out<Void>
   let presentDeferredChallenges: Out<Void>

   let didSelectChallengeIndex: Out<Int>

   //let createChallenge: VoidWork
   let reloadChallenges: VoidWork
   
   let requestPagination: VoidWork
}

final class ChallengesScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<ChallengesScenarioInputEvents, ChallengesState, ChallengesWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()

      start
         .doNext(works.loadUserDataToStore)
         .doSendEvent(events.requestPagination)

      events.presentAllChallenges
         .onSuccess(setState, .loading)
         .doNext(works.setCurrentFilterAll)
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
         .onSuccessMixSaved(setState) { .presentChallengeDetails(($1, $0)) }

//      events.createChallenge
//         .onSuccess(setState, .presentCreateChallenge)

      events.reloadChallenges
         .onSuccess(setState, .refreshing)
         .doNext(works.clearStoredChallenges)
         .doNext(works.loadChallengesForCurrentFilter)
         .onFail(setState) { .error }
         .doNext(IsNotEmpty())
         .onSuccess(setState) { .presentChallenges($0, animated: true) }
         .onFail(setState, .hereIsEmpty)
      
      events.requestPagination
         .doNext(works.loadChallengesForCurrentFilter)
         .onFail(setState) { .error }
         .doNext(IsNotEmpty())
         .onSuccess(setState) { .presentChallenges($0, animated: false) }
         .onFail(setState, .hereIsEmpty)
   }
}
