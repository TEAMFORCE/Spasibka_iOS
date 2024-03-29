//
//  ChallengeWinnersScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

struct ChallengeWinnersScenarioEvents: ScenarioPayloadedEvents {
   let payload = Out<Challenge>()
   
   let didSelectWinnerAtIndex: Out<Int>
   let winnerReportReactionRressed: Out<PressLikeRequest>
}

final class ChallengeWinnersScenario<Asset: ASP>: BasePayloadedScenario< ChallengeWinnersScenarioEvents, ChallengeWinnersState, ChallengeWinnersWorks<Asset>> {
   override func configure() {
      super.configure()
      
      start
         .doNext(works.loadChallengeWinnersReports)
         .onSuccess(setState) { .presentWinners($0) }
   
      events.didSelectWinnerAtIndex
         .doNext(works.getWinnerReportIdByIndex)
         .onSuccess(setState) { .presentReportDetailView($0) }
         .onFail { assertionFailure("fail") }
      
      events.winnerReportReactionRressed
         .doNext(works.pressLikeContender)
         .onSuccess {
            print("hello")
         }
         .onFail {
            print("hello")
         }
         .doMap { [weak self] stat in
            let index = self?.events.winnerReportReactionRressed.result?.index ?? 0
            let res = (stat, index)
            return res
         }
         .doNext(works.updateWinnerReportItem)
         .onSuccess(setState) {
            .updateWinnerAtIndex($0.0, $0.1)
         }
         .onFail {
            print("fail")
         }
   }
}
