//
//  ChallengeCandidatesWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

final class ChallengeCandidatesStore: PayloadWorkStore {
   var payload: Challenge?

   var contenders: [Contender] = []
   var winnersReports: [ChallengeWinnerReport] = []
}

final class ChallengeCandidatesWorks<Asset: ASP>: BasePayloadWorks<ChallengeCandidatesStore, Asset>, ApiUseCaseable {
   let apiUseCase = Asset.apiUseCase

   var loadChallengeContenders: Work<Void, [Contender]> { .init { [weak self] work in
      guard let id = Self.store.payload?.id else { return }

      self?.apiUseCase.getChallengeContenders
         .doAsync(id)
         .onSuccess {
            Self.store.contenders = $0
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   } }
   
   var getContenderByIndex: Work<Int, Contender> { .init { work in
      if Self.store.contenders.indices.contains(work.unsafeInput) {
         let contender = Self.store.contenders[work.unsafeInput]
         work.success(contender)
      } else {
         work.fail()
      }
   } }

   var getInputForCancel: MapWork<Int, (Challenge, Int)> { .init {
      guard
         let challenge = Self.store.payload
      else { return nil }

      return ((challenge, $0))
   } }

   var checkChallengeReport: Work<(CheckReportRequestBody.State, Int), Void> { .init { [weak self] work in
      guard
         let state = work.input?.0,
         let id = work.input?.1
      else { return }

      let request = CheckReportRequestBody(id: id, state: state, text: "")
      self?.apiUseCase.checkChallengeReport
         .doAsync(request)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   } }

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

   var updateContenderReportItem: Work<(PressLikeResult, Int), (Contender, Int)> { .init { work in
      guard
         let likeResult = work.input?.0,
         let index = work.input?.1
      else {
         work.fail()
         return
      }
      if Self.store.contenders.indices.contains(index) {
         var item = Self.store.contenders[index]
         item.update(likesAmount: likeResult.likesAmount ?? 0,
                     userLiked: likeResult.isLiked ?? false)
         Self.store.contenders[index] = item
         work.success((item, index))
      } else {
         work.fail()
      }
   } }
}
