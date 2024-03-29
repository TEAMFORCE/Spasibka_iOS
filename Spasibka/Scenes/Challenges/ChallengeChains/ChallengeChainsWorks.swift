//
//  ChallengeChainsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.09.2023.
//

import StackNinja

enum ChallengeChainsFilter {
   case none
   case all
   case active
   case deferred
}

final class ChallengeChainsTempStorage: InitProtocol {
   var userData: UserData?
   var currentOrgId: Int = 0

   var challenges: [ChallengeGroup] = []
   var activeChallenges: [ChallengeGroup] = []
   var deferredChallenges: [ChallengeGroup] = []

   var presentingChallenges: [ChallengeGroup] = []

   var currentFilter = ChalengeGroupState.active

   var allOffset = 1
   var activeOffset = 1

   var isAllPaginating = false
   var isActivePaginating = false
   let challengesPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
}

final class ChallengeChainsWorks<Asset: AssetProtocol>: BaseWorks<ChallengeChainsTempStorage, Asset> {
   private lazy var apiUseCase = Asset.apiUseCase
   private lazy var userDefaultsWorks = Asset.userDefaultsWorks
}

extension ChallengeChainsWorks: CheckInternetWorks {}

extension ChallengeChainsWorks {
   var loadUserDataToStore: VoidWork { .init { [weak self] work in
      guard let self else {
         work.fail()
         return
      }

      self.userDefaultsWorks.loadAssociatedValueWork()
         .doAsync(UserDefaultsValue.currentUser(nil))
         .onSuccess {
            Self.store.userData = $0
         }
         .onFail {
            work.fail()
         }
         .doInput(UserDefaultsValue.currentOrganizationID(nil))
         .doNext(self.userDefaultsWorks.loadAssociatedValueWork())
         .onSuccess {
            Self.store.currentOrgId = $0
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }

   var getProfileId: MapOut<Int> { .init {
      Self.store.userData?.profile.id ?? 0
   } }

   var setCurrentFilterCompleted: MapVoidWork { .init {
      Self.store.currentFilter = .closed
      Self.store.challenges = []
      Self.store.challengesPaginator.reInit()
   }}

   var setCurrentFilterActive: MapVoidWork { .init {
      Self.store.currentFilter = .active
      Self.store.challenges = []
      Self.store.challengesPaginator.reInit()
   }}

   var setCurrentFilterDeferred: MapVoidWork { .init {
      Self.store.currentFilter = .deffered
      Self.store.challenges = []
      Self.store.challengesPaginator.reInit()
   } }

   var getPresentedChallengeByIndex: MapIn<Int>.MapOut<ChallengeGroup> { .init {
      Self.store.presentingChallenges[$0]
   } }

   var createChallenge: In<ChallengeRequestBody> { .init { [weak self] work in
      guard let input = work.input else { return }
      self?.apiUseCase.createChallenge
         .doAsync(input)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }

   var loadChallengesForCurrentFilter: Out<[ChallengeGroup]> { .init { [weak self] work in

      let filter = Self.store.currentFilter
      let request = ChallengeGroupRequest(
         orgId: Self.store.currentOrgId,
         state: filter
      )

      Self.store.challengesPaginator
         .paginationForWork(self?.apiUseCase.getChallengeGroups, withRequest: request)
         .doAsync()
         .onSuccess {
            Self.store.challenges.append(contentsOf: $0)
            Self.store.presentingChallenges = Self.store.challenges
            work.success(result: Self.store.presentingChallenges)
         }
         .onFail {
            work.fail()
         }

   }.retainBy(retainer) }

   var clearStoredChallenges: MapVoidWork { .init {
      Self.store.challenges = []
      Self.store.challengesPaginator.reInit()
   } }

   //
   //   var getChallengeGroupById: Out<ChallengeGroup> { .init { [weak self] work in
   //      let request = GroupIdRequest(organizationId: 126, groupId: 1)
   //      self?.apiUseCase.getChallengeGroupById
   //         .doAsync(request)
   //         .onSuccess {
   //            print($0)
   //            work.success($0)
   //         }
   //         .onFail {
   //            work.fail()
   //         }
   //   }.retainBy(retainer) }
   //
}
