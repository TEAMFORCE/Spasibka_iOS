//
//  ChainChallengesModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.09.2023.
//

import StackNinja

final class ChainChallengesModel<Asset: ASP>: BaseViewModelWrapper<ListWithActivityViewModel<Asset.Design>>,
   PayloadedScenarible,
   Eventable,
   Assetable
{
   private(set) lazy var scenario = ChainChallengesModelScenario<Asset>(
      works: .init(),
      stateDelegate: stateDelegate,
      events: ChainChallengesModelScenarioEvents(
         didSelectItemAtIndex: presenter.on(\.didSelectItemAtIndex),
         toggleSectionVisibility: .init()
      )
   )

   typealias Events = ChainDetailsPageEvents

   var events = EventsStore()

   private let presenter = ChallengeSmallCellPresenter<Design>()

   override func start() {
      super.start()

      viewModel
         .setStates(.presenter(presenter.presenter))
         .tableModel
         .on(\.willEndDragging, self) {
            $0.send(\.willEndDragging, $1)
         }
   }
}

enum ChainChallengesModelState {
   case presentChallenges([TableItemsSection])
   case presentChallenge(Challenge)
   case toggleSectionVisibility(Int)
}

extension ChainChallengesModel: StateMachine {
   func setState(_ state: ChainChallengesModelState) {
      switch state {
      case let .presentChallenges(sections):
         viewModel
            .setStates(
               .itemSections(sections),
               .headerModelFactory { sectionIndex, section in
                  ChainCurrentStepViewModel<Design>().setup {
                     switch sectionIndex {
                     case 0:
                        $0.setStates(
                           .icon(Design.icon.chainSectionHeaderStep1),
                           .button1Icon(Design.icon.warningCircle)
                        )
                     case 1:
                        $0.setStates(
                           .icon(Design.icon.chainSectionHeaderStep2),
                           .button1Icon(Design.icon.warningCircle)
                        )
                     default:
                        $0.setStates(
                           .icon(Design.icon.chainSectionHeaderStep3),
                           .button1Icon(Design.icon.warningCircle)
                        )
                     }
                  }
                  .setNeedsStoreModelInView()
                  .setStates(
                     .button2Icon(
                        section.isCollapsed
                           ? Design.icon.navBarBackButton.rotated(byDegrees: -90)
                           : Design.icon.navBarBackButton.rotated(byDegrees: 90)
                     ),
                     .title(Design.text.step + " \(sectionIndex + 1)")
                  )
                  .on(\.didTapButton2) { [weak self] in
                     self?.scenario.events.toggleSectionVisibility.sendAsyncEvent(sectionIndex)
                  }
               }
            )
      case let .presentChallenge(challenge):
         Asset.router?.route(.push, scene: \.challengeDetails, payload: .byChallenge(challenge, chapter: .details))
      case let .toggleSectionVisibility(sectionIndex):
         viewModel.tableModel.toggleSectionCollapsed(
            at: sectionIndex,
            animated: true
         )
      }
   }
}

extension Array {
   var splitByPairs: [Array] {
      stride(from: 0, to: count, by: 2).map {
         [Element](self[$0 ..< Swift.min($0 + 2, count)])
      }
   }
}

struct ChainCellData {
   let itemsPair: [Challenge]
}
