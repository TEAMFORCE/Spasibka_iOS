//
//  ChallengeCandidatesBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

// MARK: - ChallengeCandidatesBlock

final class ChallengeCandidatesModel<Asset: AssetProtocol>:
   BaseViewModelWrapper<CandidatesViewModel<Asset.Design>>, PayloadedScenarible, Eventable
{
   typealias Events = ChallengeDetailsPageEvents
   var events = EventsStore()

   private(set) lazy var scenario = ChallengeCandidatesBlockScenario<Asset>(
      works: .init(),
      stateDelegate: stateDelegate,
      events: .init(
         didSelectContenderAtIndex: viewModel.contendersTableModel.on(\.didSelectItemAtIndex),
         acceptPressed: viewModel.presenter.on(\.acceptPressed),
         rejectPressed: viewModel.presenter.on(\.rejectPressed),
         reportReactionPressed: viewModel.presenter.on(\.reactionPressed),
         presentImage: viewModel.presenter.on(\.presentImage),
         updateContendersList: .init()
      )
   )

//   private let resultCancelledWork = Work<Void, Void>()
//   private let updateContenderList = Work<Void, Void>()

   override func start() {
      super.start()

      viewModel.contendersTableModel.on(\.willEndDragging, self) {
         $0.send(\.willEndDragging, $1)
      }
   }
}

enum ChallengeCandidatesBlockState {
   case presentContenders([Contender])
   case error
   case presentCancelView(Challenge, Int)
   case hereIsEmpty
   case updateContenderAtIndex(Contender, Int)
   case presentContendersDetail(Contender)
   case additionalCellButtonsEnabled(Bool)
}

extension ChallengeCandidatesModel: StateMachine {
   func setState(_ state: ChallengeCandidatesBlockState) {
      switch state {
      case let .presentContenders(contenders):
         viewModel.setState(.presentCandidates(contenders))
      case .error:
         break
      case let .presentCancelView(_, resultId):
         Asset.router?.route(
            .presentModally(.automatic),
            scene: \.challengeResCancel,
            payload: resultId,
            finishWork: scenario.events.updateContendersList
         )
      case .hereIsEmpty:
         break
      case let .updateContenderAtIndex(value, index):
         viewModel.contendersTableModel.updateItemAtIndex(value, index: index)
      case let .presentContendersDetail(value):
         let input = ContenderDetailsSceneInput.contender(value)
         Asset.router?.route(
            .push,
            scene: \.challengeContenderDetail,
            payload: input,
            finishWork: scenario.events.updateContendersList
         )

      case let .additionalCellButtonsEnabled(value):
         viewModel.presenter.showButtons = value
      }
   }
}
