//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

// MARK: - ChallengeDetailsBlock

final class ChallengeDetailsModel<Asset: ASP>: BaseViewModelWrapper<ChallengeDetailsViewModel<Asset.Design>>, PayloadedScenarible, Eventable
{
   private(set) lazy var scenario = ChallengeDetailsBlockScenario<Asset>(
      works: .init(),
      stateDelegate: stateDelegate,
      events: .init(
//         sendChallengeResult: .init(),
         reactionPressed: .init(),
         didTapUser: viewModel.on(\.didTapUser)
      )
   )

   typealias Events = ChallengeDetailsPageEvents
   var events = EventsStore()

   private let challengeResultDidSendWork = Work<Void, Void>()

   override func start() {
      super.start()
      
      viewModel.scrollModel.on(\.willEndDragging, self) {
         $0.send(\.willEndDragging, $1)
      }
   }
}

enum ChallengeDetailsBlockState {
   case presentSendResultScreen(Challenge)
   case presentChallenge(Challenge)
   case updateDetails(Challenge)
//   case buttonLikePressed(alreadySelected: Bool)
//   case failedToReact(alreadySelected: Bool)
//   case updateLikesAmount(Int)
   case presentUserByID(Int)
   case disableSendResult(Bool)

//   case presentResults(Challenge)
}

extension ChallengeDetailsModel: StateMachine {
   func setState(_ state: ChallengeDetailsBlockState) {
      switch state {
      case let .presentChallenge(challenge):
         viewModel.setState(.presentChallenge(challenge))

      case let .updateDetails(challenge):
         viewModel.setState(.presentChallenge(challenge))
      case let .presentSendResultScreen(challenge):
         Asset.router?.route(
            .push,
            scene: \.challengeSendResult,
            payload: challenge.id,
            finishWork: challengeResultDidSendWork
         )
//      case let .buttonLikePressed(selected):
//         if selected {
//            viewModel.likeButton.setState(.none)
//         } else {
//            viewModel.likeButton.setState(.selected)
//         }
//         break

//      case let .failedToReact(selected):
//         setState(.buttonLikePressed(alreadySelected: !selected))

//      case let .updateLikesAmount(amount):
//         viewModel.buttonsPanel.likeButton.models.right.text(String(amount))
//         break
      case let .presentUserByID(id):
         Asset.router?.route(.push, scene: \.profile, payload: id)
      case let .disableSendResult(disable):
//         viewModel.models.down.sendButton.hidden(disable)
         break
//      case let .presentResults(challenge):
//         Asset.router?.route(.push, scene: \.challengeResults, payload: inputValue)
      }
   }
}



