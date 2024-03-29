//
//  ChallengeResultsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

final class ChallengeResultsStore: PayloadWorkStore {
   var payload: Challenge?
}

final class ChallengeResultsWorks<Asset: ASP>: BasePayloadWorks<ChallengeResultsStore, Asset>, ApiUseCaseable {
   let apiUseCase = Asset.apiUseCase

   var getChallengeResult: Out<[ChallengeResult]> { .init { [weak self] work in
      guard let id = Self.store.payload?.id else { return }
      
      self?.apiUseCase.getChallengeResult
         .doAsync(id)
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }}
}
