//
//  ChallengeWinnersBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

// MARK: - ChallengeCandidatesBlock

final class ChallengeWinnersModel<Asset: AssetProtocol>: BaseViewModelWrapper<WinnersViewModel<Asset.Design>>,
                                                         PayloadedScenarible, Eventable
{
   typealias Events = ChallengeDetailsPageEvents
   var events = EventsStore()
   
   private(set) lazy var scenario = ChallengeWinnersScenario<Asset>(
      works: .init(),
      stateDelegate: stateDelegate,
      events: .init(
         didSelectWinnerAtIndex: viewModel.winnersTableModel.on(\.didSelectItemAtIndex),
         winnerReportReactionRressed: viewModel.presenter.on(\.reactionPressed)
      )
   )
   
   private let updateWinnersList = Work<Void, Void>()
   
   override func start() {
      super.start()
      
      viewModel.winnersTableModel.on(\.willEndDragging, self) {
         $0.send(\.willEndDragging, $1)
      }
   }
}

enum ChallengeWinnersState {
   case presentWinners([ChallengeWinnerReport])
   case presentReportDetailView(Int)
   case updateWinnerAtIndex(ChallengeWinnerReport, Int)
}

extension ChallengeWinnersModel: StateMachine {
   func setState(_ state: ChallengeWinnersState) {
      switch state {
      case let .presentWinners(winners):
         viewModel.setState(.presentWinners(winners))
      case let .presentReportDetailView(reportId):
         let input = ContenderDetailsSceneInput.winnerReportId(reportId)
         Asset.router?.route(
            .push,
            scene: \.challengeContenderDetail,
            payload: input,
            finishWork: updateWinnersList
         )
      case let .updateWinnerAtIndex(value, index):
         viewModel.winnersTableModel.updateItemAtIndex(value, index: index)
      }
   }
}
