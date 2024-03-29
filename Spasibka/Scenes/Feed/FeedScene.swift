//
//  FeedScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.08.2022.
//

import StackNinja
import UIKit

struct FeedSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = UserData
      typealias Output = Void
   }
}

final class FeedScene<Asset: AssetProtocol>: BaseParamsScene<FeedSceneParams<Asset>>, Scenarible {

   typealias State = ViewState
   typealias State2 = StackState

   lazy var scenario: FeedScenario<Asset> = .init(
      works: FeedWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: FeedScenarioInputEvents(
         initStorage: on(\.input),
         requestPagination: feedEventsListBlock.feedTableModel.on(\.requestPagination),
         requestRefresh: feedEventsListBlock.feedTableModel.on(\.refresh),
         didSelectItemAtIndex: feedEventsListBlock.feedTableModel.on(\.didSelectItemAtIndex),
         didTapLikeButton: cellDelegatePresenter.on(\.didTapLike),
         didTapMessagesButton: cellDelegatePresenter.on(\.didTapMessage),
         didTapFilterButtonIndex: segmentControl.on(\.didTapButtonIndex),
         didTapPopupFilterButton: mainVM.navBar.menuButton.on(\.didTap),
         didUpdatePopupFilterState: filterPopupModel.on(\.finishFiltered),
         clearSelectedFilters: allEventsFilterButton.on(\.didTap),
         didTapBirthdayButton: cellDelegatePresenter.on(\.didTapBirthdayButton)
      )
   )

   private lazy var allEventsFilterButton = SecondaryButtonDT<Design>()
      .title(Design.text.all1)
      .font(Design.font.labelRegular14)
   private lazy var segmentControl = ScrollableSegmentControl<Design>()

   private let cellDelegatePresenter = EventsCellPresenter<Design>()
   private lazy var feedEventsListBlock = FeedTableModelBlock<Design>(delegate: cellDelegatePresenter)

   private lazy var filterButton = Design.model.common.filterButton
   private lazy var bottomPopupPresenter = BottomPopupPresenter()
   private lazy var filterPopupModel = FeedFilterPopupScene<Asset>()
      .on(\.cancelled, self) {
         $0.bottomPopupPresenter.setState(.hide)
      }

   private var state = FeedSceneState.initial

   private lazy var feedDetailsRouter = FeedDetailsRouter<Asset>()

   override func start() {
      super.start()

//      vcModel?.on(\.willMoveToSuperview, self) {
//         $0.configure()
//      }

      cellDelegatePresenter.on(\.didTapLink) {
         Asset.router?.routeLink($0, navType: .push)
      }
      configure()
//      mainVM.bodyStack
//         .addModel(filterButton) { anchors, superview in
//         anchors.fitToBottomRight(superview, offset: 72.aspected, sideOffset: 16)
//      }
      scenario.configureAndStart()
   }
}

extension FeedScene: Configurable {
   func configure() {
      mainVM.navBar
         .titleLabel.text(Design.text.news)
      mainVM.navBar.menuButton.image(Design.icon.navBarMenuButton)
      
      mainVM.bodyStack
         .axis(.vertical)
         .arrangedModels([
            Grid.x16.spacer,
            segmentControl,
            Grid.x8.spacer,
            feedEventsListBlock,
            Spacer()
         ])


      configureCurrentViewModelEvents()
      scenario.configureAndStart()
      setState(.initial)
   }
}

enum FeedSceneState {
   case initial
   case loading
   case loadFeedError

   case routeToLink(URL, Bool? = nil)
   case routeToEvent(FeedEvent, Bool? = nil)

   case updateFeedAtIndex(Int, FeedEvent)

   case presentFilterButtons([FeedFilterEvent])
   case updateFilterButtonsState([Bool])
   case presentEvents([FeedEvent])
   case resetTable

   case presentFilterPopup([SelectableEventFilter])
   case hidePopup
   case setFilterButtonActive(Bool)
   
   case presentTransactScene(Int?)
}

enum EventsSceneState {
   case initial
   case present
}

extension FeedScene: StateMachine {
   func setState(_ state: FeedSceneState) {
      self.state = state
      switch state {
      case .initial:
         feedEventsListBlock.setState(.loading)
      case .loading:
         feedEventsListBlock.setState(.loading)
      case .loadFeedError:
         feedEventsListBlock.setState(.loadFeedError)
      case let .routeToLink(url, isComment):
         Asset.router?.routeLink(url, navType: .push, isComment: isComment)
      case let .updateFeedAtIndex(index, feed):
         feedEventsListBlock.feedTableModel.updateItemAtIndex(feed, index: index)

      // MARK: - New

      case let .presentEvents(events):
         feedEventsListBlock.setState(.presentEvents(events))
      case let .presentFilterButtons(filters):
         let buttons = filters.map {
            let button = SecondaryButtonDT<Design>()
               .title($0.name)
               .font(Design.font.labelRegular14)
            return button
         }

         segmentControl.setState(.buttons(buttons))
         segmentControl.stack.insertArrangedModel(allEventsFilterButton, at: 0)
      case let .updateFilterButtonsState(buttonStates):
         let selectedFiltersCount = buttonStates.filter { $0 == true }.count
         allEventsFilterButton.setMode(selectedFiltersCount != 0 ? \.normal : \.selected)
         if selectedFiltersCount != segmentControl.getButtonsCount() {
            setState(.setFilterButtonActive(selectedFiltersCount > 1))
            segmentControl.setState(.updateButtonStates(buttonStates))
         } else {
            allEventsFilterButton.setMode(\.selected)
            let buttonNewState = buttonStates.map{ !$0 }
            segmentControl.setState(.updateButtonStates(buttonNewState))
         }

//         if buttonStates.contains(true) {
//            filterButton.hidden(true)
//         } else {
//            filterButton.hidden(false)
//         }
      case .resetTable:
         feedEventsListBlock.feedTableModel.reset()
      case let .presentFilterPopup(filters):
         filterPopupModel.scenario.configureAndStart()
         filterPopupModel.scenario.events.initializeWithFilter.sendAsyncEvent(filters)
         bottomPopupPresenter.setState(
            .presentWithAutoHeight(
               model: filterPopupModel,
               onView: vcModel?.superview //view.rootSuperview
            )
         )
      case let .setFilterButtonActive(value):
         if value {
            filterButton.setMode(\.selected)
         } else {
            filterButton.setMode(\.normal)
         }
      case .hidePopup:
         bottomPopupPresenter.setState(.hide)

      case let .routeToEvent(event, isComment):
         switch event.eventSelectorType {
         case .challenge:
            var chapter = ChallengeDetailsInput.Chapter.details
            if isComment == true { chapter = .comments }
            let id = event.id
            let input = ChallengeDetailsInput.byId(id, chapter: chapter)
            Asset.router?.route(.push, scene: \.challengeDetails, payload: input)
         case .transaction:
            let id = event.id
            let input = TransactDetailsSceneInput.transactId(id, isComment)
            Asset.router?.route(.push, scene: \.transactDetails, payload: input)
         case .winner:
            let id = event.id
            let input = ContenderDetailsSceneInput.winnerReportId(id, isComment)
            Asset.router?.route(
               .push,
               scene: \.challengeContenderDetail,
               payload: input,
               finishWork: nil
            )
         case .market:
            let id = event.id
            Asset.router?.route(.push, scene: \.benefitDetails, payload: (id, .init(id: id, name: "")))
         case .none:
            break
         }
      case let .presentTransactScene(id):
         if let id = id {
            Asset.router?.route(.push, scene: \.transactions, payload: TransactSceneInput.byId(id))
         }
      }
   }

   private func configureCurrentViewModelEvents() {
//      feedEventsListBlock.feedTableModel
//         .on(\.didScroll, self) {
//            $0.send(\.didScroll, $1.velocity)
//         }
//         .on(\.willEndDragging, self) {
//            $0.send(\.willEndDragging, $1.velocity)
//         }
//         .activateRefreshControl(color: Design.color.iconBrand)
   }
}
