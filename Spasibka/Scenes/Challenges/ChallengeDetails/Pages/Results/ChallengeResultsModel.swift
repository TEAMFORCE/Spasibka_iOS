//
//  ChallengeResultsModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

// MARK: - ChallengeResultsModel

final class ChallengeResultsModel<Asset: AssetProtocol>: BaseViewModelWrapper<ChallResultsViewModel<Asset.Design>>,
   PayloadedScenarible,
   Assetable,Eventable
{
   typealias Events = ChallengeDetailsPageEvents
   var events = EventsStore()
   
   private(set) lazy var scenario = ChallengeResultsScenario<Asset>(
      works: .init(),
      stateDelegate: stateDelegate,
      events: .init(
         presentImage: viewModel.presenter.on(\.presentImage)
      )
   )

   override func start() {
      super.start()
      
      viewModel.resultsTableModel.on(\.willEndDragging, self) {
         $0.send(\.willEndDragging, $1)
      }
   }
}

enum ChallengeResultsState {
   case error
   case presentResults([ChallengeResult])
   case presentImageViewer(String)
}

extension ChallengeResultsModel: StateMachine {
   func setState(_ state: ChallengeResultsState) {
      switch state {
      case .error:
         break
      case let .presentResults(results):
         viewModel.setup(results)
      case let .presentImageViewer(imageUrl):
         Asset.router?.route(.presentModally(.automatic), scene: \.imageViewer, payload: ImageViewerInput.url(imageUrl))
      }
   }
}
