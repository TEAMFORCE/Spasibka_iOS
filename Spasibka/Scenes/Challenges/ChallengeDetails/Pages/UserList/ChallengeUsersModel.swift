//
//  ChallengeUsersModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.02.2024.
//

import StackNinja

final class ChallengeUsersModel<Asset: ASP>:
   BaseViewModelWrapper<UsersListViewModel<Asset.Design>>, PayloadedScenarible, Eventable {
   typealias Events = ChallengeDetailsPageEvents
   var events = EventsStore()

   lazy var scenario = ChallengeUsersModelScenario<Asset>(
      works: .init(),
      stateDelegate: stateDelegate,
      events: .init()
   )

   override func start() {
      super.start()

      viewModel.activityState(.error)
   }
}

enum  ChallengeUsersModelState {
   case presentUsers([UserViewModelState])
   case error
   case hereIsEmpty
}

extension ChallengeUsersModel: StateMachine {
   func setState(_ state: ChallengeUsersModelState) {
      switch state {
      case let .presentUsers(users):
         viewModel.setup(users)
      case .error:
         viewModel.activityState(.error)
      case .hereIsEmpty:
         viewModel.activityState(.empty)
      }
   }
}

