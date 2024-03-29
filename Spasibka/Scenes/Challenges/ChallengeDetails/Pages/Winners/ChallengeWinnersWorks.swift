//
//  ChallengeWinnersWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

final class ChallengeWinnersStore: PayloadWorkStore {
   var payload: Challenge?

   var contenders: [Contender] = []
   var winnersReports: [ChallengeWinnerReport] = []
}

final class ChallengeWinnersWorks<Asset: ASP>: BasePayloadWorks<ChallengeWinnersStore, Asset>, ApiUseCaseable {
   let apiUseCase = Asset.apiUseCase

   var getChallengeWinners: Work<Void, [ChallengeWinner]> { .init { [weak self] work in
      guard let id = Self.store.payload?.id else { return }

      self?.apiUseCase.getChallengeWinners
         .doAsync(id)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   } }

   var updateWinnerReportItem: Work<(PressLikeResult, Int), (ChallengeWinnerReport, Int)> { .init { work in
      guard
         let likeResult = work.input?.0,
         let index = work.input?.1
      else {
         work.fail()
         return
      }
      if Self.store.winnersReports.indices.contains(index) {
         var item = Self.store.winnersReports[index]
         item.update(likesAmount: likeResult.likesAmount ?? 0,
                     userLiked: likeResult.isLiked ?? false)
         Self.store.winnersReports[index] = item
         work.success((item, index))
      } else {
         work.fail()
      }
   } }
   
   var loadChallengeWinnersReports: Work<Void, [ChallengeWinnerReport]> { .init { [weak self] work in
      guard let id = Self.store.payload?.id else { return }
      
      self?.apiUseCase.getChallengeWinnersReports
         .doAsync(id)
         .onSuccess {
            Self.store.winnersReports = $0
            work.success(result: Self.store.winnersReports)
         }
         .onFail {
            work.fail()
         }
   }}
   
   var getWinnerReportIdByIndex: Work<Int, Int> { .init { work in
      let id = Self.store.winnersReports[work.unsafeInput].id
      work.success(id)
   } }
   
   var pressLikeContender: Work<PressLikeRequest, PressLikeResult> { .init { [weak self] work in
      guard let input = work.input else { work.fail(); return }
      self?.apiUseCase.pressLike
         .doAsync(input)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   } }
}
