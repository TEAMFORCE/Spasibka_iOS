//
//  NewChallengeChainWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 22.01.2024.
//

import StackNinja

final class ChallengeChainsBaseStore {
   var userDataAndOrgId: (UserData, Int)?

   var userData: UserData?
   var currentOrgId: Int = 0
   var challenges: [ChallengeGroup] = []
   var presentingChallenges: [ChallengeGroup] = []
   var currentFilter = ChalengeGroupState.active
   let challengesPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
}

final class NewChallengeChainWorks<Asset: ASP>: WorksProtocol {
   let store = ChallengeChainsBaseStore()
   let retainer = Retainer()
   let apiUseCase = Asset.apiUseCase
   let userDefaultsWorks = Asset.userDefaultsWorks

   var loadUserDataToStore: VoidWork { .init { [weak self] work in
      guard let self else {
         work.fail()
         return
      }

      self.userDefaultsWorks.loadAssociatedValueWork()
         .doAsync(UserDefaultsValue.currentUser(nil))
         .onSuccess {
            self.store.userData = $0
         }
         .onFail {
            work.fail()
         }
         .doInput(UserDefaultsValue.currentOrganizationID(nil))
         .doNext(self.userDefaultsWorks.loadAssociatedValueWork())
         .onSuccess {
            self.store.currentOrgId = $0
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }

   var loadChallengesForCurrentFilter: Out<[ChallengeGroup]> { .init { [weak self] work in
      guard let self else {
         return
      }

      let filter = self.store.currentFilter
      let request = ChallengeGroupRequest(
         orgId: self.store.currentOrgId,
         state: filter
      )

      self.store.challengesPaginator
         .paginationForWork(self.apiUseCase.getChallengeGroups, withRequest: request)
         .doAsync()
         .onSuccess {
            self.store.challenges.append(contentsOf: $0)
            self.store.presentingChallenges = self.store.challenges
            work.success(result: self.store.presentingChallenges)
         }
         .onFail {
            work.fail()
         }

   }.retainBy(retainer) }

   var getChallengeGroupByIndex: In<Int>.Out<ChallengeGroup> { .init { [weak self] work in
      guard let self else {
         return
      }

      let index = work.in
      let challenge = self.store.presentingChallenges[index]

      work.success(result: challenge)
   }.retainBy(retainer) }
}

struct ChallengeChainsPreviewScenarioEvents: ScenarioEvents {
   let presentAllChallenges: Out<Void>
   let didSelectCollectionItemAtIndex: Out<Int>
}

final class ChallengeChainsPreviewScenario<Asset: ASP>: BaseWorkableScenario<
   ChallengeChainsPreviewScenarioEvents,
   ChallengeChainsCollectionState,
   NewChallengeChainWorks<Asset>
> {
   override func configure() {
      super.configure()

      start
         .doNext(works.loadUserDataToStore)
         .doSendEvent(events.presentAllChallenges)

      events.presentAllChallenges
         .doNext(works.loadChallengesForCurrentFilter)
         .onSuccess(setState) { .presentChallenges($0) }
         .onFail(setState, .error)

      events.didSelectCollectionItemAtIndex
         .doNext(works.getChallengeGroupByIndex)
         .onSuccess(setState) { .presentChallenge($0) }
   }
}
