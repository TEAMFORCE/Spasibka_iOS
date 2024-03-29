//
//  ChallengeChainsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.09.2023.
//

import StackNinja
import UIKit

final class ChallengeChainsMainViewModel<Asset: ASP>: VStackModel,
   Assetable,
   Eventable,
   Scenarible
{
   typealias Events = MainSubsceneEvents
   var events: EventsStore = .init()

   // MARK: - Scenario

   private(set) lazy var scenario = ChallengeChainsScenario(
      works: ChallengeChainsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: .init(
         completedChains: filterButtons.on(\.didTapCompletedChains),
         presentActiveChallenges: filterButtons.on(\.didTapFilterActive),
         presentDeferredChallenges: filterButtons.on(\.didTapFilterDeferred),
         didSelectChallengeIndex: challengeGroupsTable.on(\.didSelectItemAtIndex),
         createChallenge: .init(), // createChallengeButton.on(\.didTap),
         reloadChallenges: .init(),
         requestPagination: challengeGroupsTable.on(\.requestPagination)
      )
   )

   private lazy var didChallengeCreated = Out<FinishEditChallengeEvent>()
      .onSuccess(self) {
         $0.scenario.events.reloadChallenges.sendAsyncEvent()
      }

   // MARK: - View Models

   private lazy var filterButtons = ChallengesFilterButtons<Design>()
      .padHorizontal(16)

   private lazy var challengeGroupsTable = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         ChallengeChainCellPresenter<Design>.presenter
      )
      .footerModel(Spacer(96))
      .setNeedsLayoutWhenContentChanged()

//   private lazy var createChallengeButton = ButtonModel()
//      .set(Design.state.button.default)
//      .size(.square(38))
//      .cornerRadius(38 / 2)
//      .backColor(Design.color.backgroundBrand)
//      .image(Design.icon.tablerPlus, color: Design.color.iconInvert)

   private lazy var activityBlock = Design.model.common.activityIndicatorSpaced
      .hidden(true)
   private lazy var errorBlock = Design.model.common.connectionErrorBlock
      .hidden(true)
   private lazy var hereIsEmprtyBlock = Design.model.common.hereIsEmptySpaced
      .hidden(true)

   // MARK: - Start

   override func start() {
      padding(.horizontalOffset(0))
      arrangedModels([
         filterButtons,
         Grid.x16.spacer,
         activityBlock,
         errorBlock,
         hereIsEmprtyBlock,
         challengeGroupsTable
      ])
      setState(.initial)

      challengeGroupsTable
         .on(\.didScroll) { [weak self] in
            self?.send(\.didScroll, $0.velocity)
         }
         .on(\.willEndDragging) { [weak self] in
            if $0.velocity > 0 {
//               self?.filterButtons.hidden(true, isAnimated: true)
//               self?.createChallengeButton.hidden(true, isAnimated: true)
            } else if $0.velocity < 0 {
//               self?.filterButtons.hidden(false, isAnimated: true)
//               self?.createChallengeButton.hidden(false, isAnimated: true)
            }
            self?.send(\.willEndDragging, $0.velocity)
         }
         .activateRefreshControl(color: Design.color.iconBrand)
         .on(\.refresh, self) {
            $0.scenario.configureAndStart() // TODO: - new event make
         }
   }
}

enum ChallengeChainsState {
   case initial
   //
   case presentChallenges([ChallengeGroup])
   case presentChainDetails((chain: ChallengeGroup, profileId: Int)) // challenge and profileId
   case presentCreateChallenge
   //   case presentTemplates
   //
   case loading
   case success
   case error
   case hereIsEmpty
}

extension ChallengeChainsMainViewModel: StateMachine {
   func setState(_ state: ChallengeChainsState) {
      switch state {
      case .initial:
         setState(.loading)
      case let .presentChallenges(challenges):
         setState(.success)
         challengeGroupsTable.items(challenges)
      case .success:
         activityBlock.hidden(true)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(true)
         challengeGroupsTable.hidden(false)
      case .loading:
         activityBlock.hidden(false)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(true)
         challengeGroupsTable.hidden(true)
      case .error:
         activityBlock.hidden(true)
         errorBlock.hidden(false)
         hereIsEmprtyBlock.hidden(true)
         challengeGroupsTable.hidden(true)
      case .hereIsEmpty:
         activityBlock.hidden(true)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(false)
         challengeGroupsTable.hidden(true)
      //
      case let .presentChainDetails(value):
         Asset.router?.route(
            .push,
            scene: \.chainDetails,
            payload: .byChain(value.chain, chapter: .details),
            finishWork: scenario.events.reloadChallenges
         )
      case .presentCreateChallenge:
         break
//         Asset.router?.route(
//            .presentModally(.pageSheet),
//            scene: \.challengeCreate,
//            payload: .createChallenge,
//            finishWork: didChallengeCreated
//         )
      }
   }
}
