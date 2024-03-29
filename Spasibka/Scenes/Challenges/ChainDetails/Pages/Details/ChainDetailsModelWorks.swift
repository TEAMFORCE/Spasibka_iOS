//
//  ChainDetailsModelWork.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja

final class ChainDetailsModelStore: PayloadWorkStore {
   var payload: ChallengeGroup?
}

final class ChainDetailsModelWorks<Asset: ASP>: BasePayloadWorks<ChainDetailsModelStore, Asset>, ApiUseCaseable {
   let apiUseCase = Asset.apiUseCase
   let userDefaultsWorks = Asset.userDefaultsWorks
   
   var loadChainDetailsToStore: VoidWork { .init { [weak self] work in
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
            GroupIdRequest(organizationId: $0, groupId: chainId)
         }
         .doNext(self.apiUseCase.getChallengeGroupById)
         .onSuccess {
            Self.store.payload = $0
            work.success()
         }
         .onFail {
            work.fail()
         }
   }}
   
   func getChainDetails() -> ChallengeGroup? {
      Self.store.payload
   }
   
   func getAuthorID() -> Int? {
      Self.store.payload?.authorId
   }
}
