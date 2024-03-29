//
//  ChainChallengesModelWork.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja

final class ChainChallengesModelStore: PayloadWorkStore {
   var payload: ChallengeGroup?

   var challenges: [Challenge] = []

   let paginator = PaginationSystem(pageSize: 1000, startOffset: 1)
   
   var sectionVisibilities: [Bool] = []
}

final class ChainChallengesModelWorks<Asset: ASP>: BasePayloadWorks<ChainChallengesModelStore, Asset>, ApiUseCaseable {
   let apiUseCase = Asset.apiUseCase
   let userDefaultsWorks = Asset.userDefaultsWorks
   
   var loadChallengesChainToStore: VoidWork { .init { [weak self] work in
      guard let self, let chainId = Self.store.payload?.id else {
         work.fail()
         return
      }

      let request = ChallengesRequest(activeOnly: false, deferredOnly: false, groupID: chainId)

      Self.store.paginator.reInit()
      Self.store.paginator
         .paginationForWork(self.apiUseCase.getChanllenges, withRequest: request)
         .doAsync()
         .onSuccess {
            Self.store.challenges = $0
            work.success()
         }
         .onFail {
            work.fail()
         }
   }}

   func getChallenges() -> [Challenge] {
      Self.store.challenges
   }

   func getChallenge(_ index: Int) -> Challenge {
      Self.store.challenges[index]
   }
   
   func storeSectionVisibilities(_ sections: [[Challenge]]) -> [[Challenge]] {
      let currentStep = Self.store.payload?.tasksFinished.unwrap
      if Self.store.sectionVisibilities.isEmpty {
         sections.enumerated().forEach { index, value in
            Self.store.sectionVisibilities.append(index != currentStep)
         }
      }
      
      return sections
   }
   
   func getSectionVisibilities() -> [Bool] {
      Self.store.sectionVisibilities
   }
   
   func toggleSectionVisibility(_ index: Int) -> Int {
      Self.store.sectionVisibilities[index].toggle()
      return index
   }

   func getChallengeSections() -> [[Challenge]] {
      let sections = Self.store.challenges
         .sorted { $0.step.unwrap < $1.step.unwrap }
         .reduce(into: [[Challenge]]()) { partialResult, chall in
            if chall.step == partialResult.last?.last?.step {
               partialResult[partialResult.count - 1].append(chall)
            } else {
               partialResult.append([chall])
            }
         }
      
      return sections
   }
}

private func makeChallengeMockArray(_ randomMax: Int) -> [Challenge] {
   (0 ... Int.random(in: 0 ... randomMax)).map { _ in
      Challenge.makeRandomMock()
   }
}
