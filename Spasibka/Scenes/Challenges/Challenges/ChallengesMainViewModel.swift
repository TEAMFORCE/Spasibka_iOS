//
//  ChallengesViewModels.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 06.10.2022.
//

import StackNinja
import UIKit

final class ChallengesMainViewModel<Asset: AssetProtocol>: VStackModel,
   Assetable,
   Eventable,
   Scenarible
{
   typealias Events = MainSubsceneEvents
   var events: EventsStore = .init()

   // MARK: - Scenario

   private(set) lazy var scenario = ChallengesScenario(
      works: ChallengesWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: ChallengesScenarioInputEvents(
         presentAllChallenges: filterButtons.on(\.didTapCompletedChains),
         presentActiveChallenges: filterButtons.on(\.didTapFilterActive),
         presentDeferredChallenges: filterButtons.on(\.didTapFilterDeferred),
         didSelectChallengeIndex: challListBlock.on(\.didSelectChallenge),
         //createChallenge: createChallengeButton.on(\.didTap),
         reloadChallenges: .init(),
         requestPagination: challListBlock.challengesTable.on(\.requestPagination)
      )
   )

//   private lazy var didChallengeCreated = Out<FinishEditChallengeEvent>()
//      .onSuccess(self) {
//         $0.scenario.events.reloadChallenges.sendAsyncEvent()
//      }

   // MARK: - View Models

   private lazy var filterButtonsContainer = VStackModel(
      filterButtons
         .padHorizontal(16),
      Grid.x16.spacer
   )

   private lazy var filterButtons = ChallengesFilterButtons<Design>()

   private lazy var challListBlock = ChallengesViewModel<Design>()

//   private lazy var createChallengeButton = ButtonModel()
//      .set(Design.state.button.default)
//      .size(.square(38))
//      .cornerRadius(38 / 2)
//      .backColor(Design.color.backgroundBrand)
//      .image(Design.icon.tablerPlus, color: Design.color.iconInvert)

   private lazy var activityBlock = Design.model.common.activityIndicator
      .hidden(true)
   private lazy var errorBlock = Design.model.common.connectionErrorBlock
      .hidden(true)
   private lazy var hereIsEmprtyBlock = Design.model.common.hereIsEmptySpaced
      .hidden(true)

   // MARK: - Init

   private var isFilterButtonsEnabled: Bool = false
   convenience init(isFilterButtonsEnabled: Bool) {
      self.init()
      self.isFilterButtonsEnabled = isFilterButtonsEnabled
   }

   // MARK: - Start

   override func start() {
      padding(.horizontalOffset(0))
      arrangedModels(
         [
            isFilterButtonsEnabled ? filterButtonsContainer : nil,
            activityBlock,
            errorBlock,
            hereIsEmprtyBlock,
            challListBlock,
            Spacer()
         ]
         .compactMap { $0 }
      )
      setState(.initial)

      challListBlock.challengesTable
         .on(\.didScroll) { [weak self] in
            self?.send(\.didScroll, $0.velocity)
         }
         .on(\.willEndDragging) { [weak self] in
            self?.send(\.willEndDragging, $0.velocity)
         }
         .activateRefreshControl(color: Design.color.iconBrand)
         .on(\.refresh, self) {
            $0.scenario.events.reloadChallenges.sendAsyncEvent()
         }
   }
}

enum ChallengesState {
   case initial
   //
   case presentChallenges([Challenge], animated: Bool)
   case presentChallengeDetails((challenge: Challenge, profileId: Int)) // challenge and profileId
//   case presentCreateChallenge
   //
   case loading
   case refreshing
   case error
   case hereIsEmpty
}

extension ChallengesMainViewModel: StateMachine {
   func setState(_ state: ChallengesState) {
      switch state {
      case .initial:
         setState(.loading)
      //
      case let .presentChallenges(challenges, animated):
         activityBlock.hidden(true, isAnimated: animated)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(true)
         challListBlock.hidden(false)
         challListBlock.setState(.presentChallenges(challenges))
      case .loading:
         activityBlock.hidden(false)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(true)
         challListBlock.hidden(true)
      case .refreshing:
         activityBlock.hidden(false, isAnimated: true)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(true)
      case .error:
         activityBlock.hidden(true)
         errorBlock.hidden(false)
         hereIsEmprtyBlock.hidden(true)
         challListBlock.hidden(true)
      case .hereIsEmpty:
         activityBlock.hidden(true)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(false)
         challListBlock.hidden(true)
      //
      case let .presentChallengeDetails(value):
         Asset.router?.route(
            .push,
            scene: \.challengeDetails,
            payload: ChallengeDetailsInput.byChallenge(value.challenge),
            finishWork: scenario.events.reloadChallenges
         )
//      case .presentCreateChallenge:
//         Asset.router?.route(
//            .presentModally(.pageSheet),
//            scene: \.challengeCreate,
//            payload: .createChallenge,
//            finishWork: didChallengeCreated
//         )
      }
   }
}
