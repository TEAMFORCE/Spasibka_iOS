//
//  ChallengeReactionsBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

// MARK: - ChallengeReactionsBlock

final class ChallengeReactionsModel<Asset: AssetProtocol>: BaseViewModelWrapper<ReactItemsViewModel<Asset.Design>>,
   PayloadedScenarible, Eventable
{
   typealias Events = ChallengeDetailsPageEvents
   var events = EventsStore()

   private(set) lazy var scenario = ChallengeReactionsScenario<Asset>(
      works: .init(),
      stateDelegate: stateDelegate,
      events: .init()
   )

   override func start() {
      super.start()

      viewModel.reactedUsersTableModel.on(\.willEndDragging, self) {
         $0.send(\.willEndDragging, $1)
      }
   }
}

enum ChallengeReactionsState {
   case error
   case presentReactions([ReactItem])
}

extension ChallengeReactionsModel: StateMachine {
   func setState(_ state: ChallengeReactionsState) {
      switch state {
      case .error:
         break
      case let .presentReactions(reactions):
         viewModel.setup(reactions)
      }
   }
}
