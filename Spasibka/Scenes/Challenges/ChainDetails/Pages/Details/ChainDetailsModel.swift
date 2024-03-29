//
//  ChainDetailsModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja

final class ChainDetailsModel<Asset: ASP>: BaseViewModelWrapper<ChainDetailsViewModel<Asset.Design>>,
   PayloadedScenarible,
   Eventable
{
   private(set) lazy var scenario = ChainDetailsModelScenario<Asset>(
      works: .init(),
      stateDelegate: stateDelegate,
      events: ChainDetailsModelScenarioEvents(
         didTapUser: viewModel.on(\.didTapUser)
      )
   )

   typealias Events = ChainDetailsPageEvents

   var events = EventsStore()
   
   override func start() {
      super.start()
      
      viewModel.scrollModel.on(\.willEndDragging, self) {
         $0.send(\.willEndDragging, $1)
      }
   }
}

enum ChainDetailsModelState {
   case presentDetails(ChallengeGroup)
   case presentAuthor(Int)
   case updateChainDetails(ChallengeGroup)
}

extension ChainDetailsModel: StateMachine {
   func setState(_ state: ChainDetailsModelState) {
      switch state {
      case let .presentDetails(details):
         viewModel.setState(.init(
            name: details.name,
            description: details.description,
            
            progressTotal: details.tasksTotal,
            progressCurrent: details.tasksFinished,
            
            startAt: details.startAt?.dateFormatted(.dMMMyHHmm),
            endAt: details.endAt?.dateFormatted(.dMMMyHHmm),
            
            fromOrganization: false,
            organizationName: nil,
            
            creatorName: Asset.Design.text.organizer,
            creatorSurname: nil,
            creatorTgName: details.author,
            creatorPhoto: details.authorPhoto
         ))
         viewModel.view.layoutIfNeeded()
      case let .presentAuthor(authorID):
         Asset.router?.route(
            .push,
            scene: \.profile,
            payload: authorID
         )
      case .updateChainDetails(let chain):
         self.setState(.presentDetails(chain))
       //  send(\.updateChainDetails, chain)
      }
   }
}
