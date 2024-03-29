//
//  ChallengesWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 06.10.2022.
//

import StackNinja

final class ChallengesTempStorage: InitProtocol {
   enum Filter {
      case none
      case all
      case active
      case deferred
   }

   var userData: UserData?

   var challenges: [Challenge] = []
   var presentingChallenges: [Challenge] = []

   var currentFilter = Filter.active
   let challengesPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
   
}

final class ChallengesWorks<Asset: AssetProtocol>: BaseWorks<ChallengesTempStorage, Asset> {
   private lazy var apiUseCase = Asset.apiUseCase
   private lazy var userDefaultsWorks = Asset.userDefaultsWorks
}

extension ChallengesWorks: CheckInternetWorks {}

extension ChallengesWorks {
   var loadUserDataToStore: VoidWork { .init { [weak self] work in
      self?.userDefaultsWorks.loadAssociatedValueWork()
         .doAsync(UserDefaultsValue.currentUser(nil))
         .onSuccess {
            Self.store.userData = $0
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }

   var getProfileId: MapOut<Int> { .init {
      Self.store.userData?.profile.id ?? 0
   } }

   var setCurrentFilterAll: MapVoidWork { .init {
      Self.store.currentFilter = .all
      Self.store.challenges = []
      Self.store.challengesPaginator.reInit()
   }}

   var setCurrentFilterActive: MapVoidWork { .init {
      Self.store.currentFilter = .active
      Self.store.challenges = []
      Self.store.challengesPaginator.reInit()
   }}
   
   var setCurrentFilterDeferred: MapVoidWork { .init {
      Self.store.currentFilter = .deferred
      Self.store.challenges = []
      Self.store.challengesPaginator.reInit()
   } }

   var getPresentedChallengeByIndex: MapIn<Int>.MapOut<Challenge> { .init {
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

   var loadChallengesForCurrentFilter: Out<[Challenge]> { .init { [weak self] work in

      let filter = Self.store.currentFilter
      let request = ChallengesRequest(
         activeOnly: filter == .active,
         deferredOnly: filter == .deferred,
         groupID: nil
      )

      Self.store.challengesPaginator
         .paginationForWork(self?.apiUseCase.getChanllenges, withRequest: request)
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
}
