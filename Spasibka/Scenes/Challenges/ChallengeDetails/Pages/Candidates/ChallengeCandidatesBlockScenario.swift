//
//  ChallengeCandidatesBlockScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

struct ChallengeCandidatesBlockScenarioEvents: ScenarioPayloadedEvents {
   let payload = Out<Challenge>()

   let didSelectContenderAtIndex: Out<Int>
   let acceptPressed: Out<Int>
   let rejectPressed: Out<Int>
   let reportReactionPressed: Out<PressLikeRequest>
   let presentImage: Out<String>
   let updateContendersList: VoidWork
}

final class ChallengeCandidatesBlockScenario<Asset: ASP>: BasePayloadedScenario<
   ChallengeCandidatesBlockScenarioEvents,
   ChallengeCandidatesBlockState,
   ChallengeCandidatesWorks<Asset>
> {
   override func configure() {
      super.configure()

      start
         .doNext(works.loadChallengeContenders)
         .onSuccess(setState) { .presentContenders($0) }
         .onFail(setState, .error)

      events.updateContendersList
         .doNext(works.loadChallengeContenders)
         .onSuccess(setState) { .presentContenders($0) }
         .onFail(setState, .error)
      
      events.rejectPressed
         .doNext(works.getInputForCancel)
         .onSuccess(setState) {
            .presentCancelView($0.0, $0.1)
         }

      events.acceptPressed
         .doMap { (CheckReportRequestBody.State.W, $0) }
         .doNext(works.checkChallengeReport)
         .doNext(works.loadChallengeContenders)
         .onSuccess { [weak self] contenders in
//            print(contenders)
//            guard !contenders.isEmpty else {
//               self?.setState(.hereIsEmpty);
//               return }

            self?.setState(.presentContenders(contenders))
         }
         .onFail { assertionFailure("fail") }
//         .doVoidNext(works.getChallengeWinners)
//         .onSuccess { [weak self] winners in
//            if !winners.isEmpty {
//               // self?.setState(.enableWinners)
//            }
//         }

      events.reportReactionPressed
         .doNext(works.pressLikeContender)
         .onSuccess {
            print("hello")
         }
         .doMap { [weak self] stat in
            let index = self?.events.reportReactionPressed.result?.index ?? 0
            let res = (stat, index)
            return res
         }
         .doNext(works.updateContenderReportItem)
         .onSuccess(setState) {
            .updateContenderAtIndex($0.0, $0.1)
         }
         .onFail {
            print("fail")
         }

      events.presentImage
         .onSuccess {
            Asset.router?.route(.presentModally(.automatic), scene: \.imageViewer, payload: ImageViewerInput.url($0))
         }

      events.didSelectContenderAtIndex
         .doNext(works.getContenderByIndex)
         .onSuccess(setState) { .presentContendersDetail($0) }
         .onFail { assertionFailure("fail") }
   }
}
