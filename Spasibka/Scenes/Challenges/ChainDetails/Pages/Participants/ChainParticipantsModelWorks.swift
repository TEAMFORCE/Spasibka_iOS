//
//  ChainParticipantsModelWork.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja

final class ChainParticipantsModelStore: PayloadWorkStore {
   var payload: ChallengeGroup?
   
   var participants: [ChainParticipant] = []
}

final class ChainParticipantsModelWorks<Asset: ASP>: BasePayloadWorks<ChainParticipantsModelStore, Asset>, ApiUseCaseable {
   let apiUseCase = Asset.apiUseCase
   let userDefaultsWorks = Asset.userDefaultsWorks
   
   var loadParticipantsToStore: VoidWork { .init { [weak self] work in
      guard let self, let chainId = Self.store.payload?.id else {
         work.fail()
         return
      }
      
      self.userDefaultsWorks.loadAssociatedValueWork()
         .doAsync(UserDefaultsValue.currentOrganizationID(nil))
         .onFail {
            work.fail()
         }
         .doMap {
            ChainParticipantsRequest(organizationID: $0, chainID: chainId)
         }
         .doNext(self.apiUseCase.getChainParticipants)
         .onSuccess {
            Self.store.participants = $0.data
            work.success()
         }
         .onFail {
            work.fail()
         }
   }}
   
   func getParticipants() -> [ChainParticipant] {
      Self.store.participants
   }
   
   func getParticipant(_ id: Int) -> ChainParticipant {
      Self.store.participants[id]
   }
}
