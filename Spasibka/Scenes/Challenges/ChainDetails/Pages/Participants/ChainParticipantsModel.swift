//
//  ChainParticipantsModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja

final class ChainParticipantsModel<Asset: ASP>: BaseViewModelWrapper<ListWithActivityViewModel<Asset.Design>>,
   PayloadedScenarible,
   Eventable,
   Assetable
{
   private(set) lazy var scenario = ChainParticipantsModelScenario<Asset>(
      works: .init(),
      stateDelegate: stateDelegate,
      events: ChainParticipantsModelScenarioEvents(
         didSelectItemAtIndex: viewModel.on(\.didSelectItemAtIndex)
      )
   )

   typealias Events = ChainDetailsPageEvents

   var events = EventsStore()

   override func start() {
      super.start()

      viewModel.setState(.presenter(UserCellPresenter<Design>.presenter))
      viewModel.tableModel.on(\.willEndDragging, self) {
         $0.send(\.willEndDragging, $1)
      }
   }
}

enum ChainParticipantsModelState {
   case presentItems([ChainParticipant])
   case presentParticipant(ChainParticipant)
}

extension ChainParticipantsModel: StateMachine {
   func setState(_ state: ChainParticipantsModelState) {
      switch state {
      case let .presentItems(items):
         let states = items.map {
            let names = $0.participantName.components(separatedBy: " ")
            return UserViewModelState(
               imageUrl: SpasibkaEndpoints.tryConvertToImageUrl($0.participantPhoto),
               name: names[safe: 0],
               surname: names[safe: 1],
               caption: nil
            )
         }
         viewModel.setState(.items(states))
      case .presentParticipant(let participant):
         Asset.router?.route(.push, scene: \.profile, payload: participant.participantID)
      }
   }
}
