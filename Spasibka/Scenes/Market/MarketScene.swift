//
//  MarketScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 12.01.2023.
//

import StackNinja

enum MarketSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyFooterStack<Asset, PresentInitial>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class MarketScene<Asset: ASP>: BaseParamsScene<MarketSceneParams<Asset>> {

   // MARK: - Scenario

   lazy var scenario = MarketScenario(
      works: MarketWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: MarketScenarioInputEvents(
//         payload: on(\.input),
         didSelectBenefitIndex: benefitsViewModel.on(\.didSelectBenefit),
         searchFilter: benefitsViewModel.on(\.didTapSearchButton),
         presentBasket: mainVM.navBar.basketButton.on(\.didTap),
         presentPurchaseHistory: mainVM.navBar.purchaseHistoryButton.on(\.didTap),
         requestPagination: benefitsViewModel.benefitsTable.on(\.requestPagination),
         didTapPopupFilterButton: benefitsViewModel.filterButton.on(\.didTap),
         didUpdatePopupFilterState: filterPopupModel.on(\.finishFiltered),
         didTapCategory: benefitsViewModel.segmentControl.on(\.didTapButtonIndex),
         didTapCategoryAll: allCategoriesButton.on(\.didTap),
         clearTextField: benefitsViewModel.searchField.on(\.textFieldShouldClear),
         didSelectBenefitWithId: benefitsViewModel.on(\.didSelectBenefitWithId),
         didTapTextFieldReturnButton: benefitsViewModel.searchField.on(\.textFieldShouldReturn)
      )
   )

   // MARK: - View Models

   private lazy var benefitsViewModel = BenefitsViewModel<Design>()

   private lazy var activityBlock = Design.model.common.activityIndicatorSpaced
      .hidden(true)
   private lazy var errorBlock = Design.model.common.connectionErrorBlock
      .hidden(true)
   private lazy var hereIsEmprtyBlock = Design.model.common.hereIsEmptySpaced
      .hidden(true)

   private lazy var darkLoader = DarkLoaderVM<Design>()
   
   private lazy var bottomPopupPresenter = BottomPopupPresenter()
   private lazy var filterPopupModel = MarketFilterScene<Asset>()
      .on(\.cancelled, self) {
         $0.bottomPopupPresenter.setState(.hide)
      }
   
   private lazy var allCategoriesButton = BenefitFilterButton<Design>()
      .setStates(
         .text(Design.text.all1),
         .image(Design.icon.tablerCategory2)
      )

   override func start() {
      mainVM.setBenefitNavBar()
      mainVM.navBar.titleLabel
         .text(Design.text.benefits)
      
      
//      mainVM.navBar.menuButton.image(Design.icon.basket.withTintColor(Design.color.text))
      setState(.initial)
      scenario.configureAndStart()
//      benefitsViewModel.benefitsTable
//         .on(\.didScroll, self) {
//            $0.send(\.didScroll, $1.velocity)
//         }
//         .on(\.willEndDragging, self) {
//            $0.send(\.willEndDragging, $1.velocity)
//            if $1.velocity > 0 {
//               $0.benefitsViewModel.setState(.hideFilter)
//            } else if $1.velocity <= 0 {
//               $0.benefitsViewModel.setState(.presentFilter)
//            }
//         }
//         .activateRefreshControl(color: Design.color.iconBrand)
//         .on(\.refresh, self) {
//            $0.scenario.configureAndStart()
//         }

//      benefitsViewModel.filterButton.on(\.didTap, self) {
//         $0.send(\.presentMarketFilterScene)
//      }

//      benefitsViewModel.basketButton.on(\.didTap) {
//         Asset.router?.route(.push, scene: \.benefitBasket)
//      }
      
//      benefitsViewModel.historyButton.on(\.didTap) {
//         Asset.router?.route(.presentModally(.automatic), scene: \.benefitsPurchaseHistory)
//      }
   }
}

enum MarketState {
   case initial
   //
   case presentBenefits([Benefit])
   case presentBenefitDetails((Int, Market))
   case loading
   case success
   case error
   case hereIsEmpty
   case filterButtonSelected(Bool)
   case presentBasket(Market)
   case presentPurchaseHistory(Market)
   case presentFilterPopup(MarketFilterPopupInput)
   case hidePopup
   case setCategories([String])
   case updateSelectedCatefory(Int)
   case categoryAllSelected
}

extension MarketScene: StateMachine {
   func setState(_ state: MarketState) {
      switch state {
      case .initial:
         mainVM.bodyStack
            .arrangedModels([
               activityBlock,
               errorBlock,
               hereIsEmprtyBlock,
               benefitsViewModel,
            ])
            .padding(.horizontalOffset(16))
            .clipsToBound(true)
         
         setState(.loading)
         //
      case .presentBenefits(let benefits):
         bottomPopupPresenter.setState(.hide)
         setState(.success)
         benefitsViewModel.setState(.presentBenefits(benefits))
      case .success:
         activityBlock.hidden(true)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(true)
         benefitsViewModel.hidden(false)
      case .loading:
         activityBlock.hidden(false)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(true)
         benefitsViewModel.hidden(true)
      case .error:
         activityBlock.hidden(true)
         errorBlock.hidden(false)
         hereIsEmprtyBlock.hidden(true)
         benefitsViewModel.hidden(true)
      case .hereIsEmpty:
         activityBlock.hidden(true)
         errorBlock.hidden(true)
         hereIsEmprtyBlock.hidden(false)
         benefitsViewModel.hidden(true)
      //
      case .presentBenefitDetails(let value):
         Asset.router?.route(
            .push,
            scene: \.benefitDetails,
            payload: value
         )
      case .filterButtonSelected(let value):
//         if value {
//            benefitsViewModel.filterButton.setMode(\.selected)
//         } else {
//            benefitsViewModel.filterButton.setMode(\.normal)
//         }
         print("hi")
         break
      case .presentBasket(let value):
         Asset.router?.route(
            .push,
            scene: \.benefitBasket,
            payload: value
         )
      case .presentPurchaseHistory(let value):
         Asset.router?.route(
            .presentModally(.automatic),
            scene: \.benefitsPurchaseHistory,
            payload: value
         )
      case .presentFilterPopup(let value):
         filterPopupModel.scenario.configureAndStart()
         filterPopupModel.scenario.events.initializeWithFilters.sendAsyncEvent(value)
         bottomPopupPresenter.setState(
            .presentWithAutoHeight(
               model: filterPopupModel,
               onView: vcModel?.superview //view.rootSuperview
            )
         )
      case .hidePopup:
         bottomPopupPresenter.setState(.hide)
      case .setCategories(let categories):
         benefitsViewModel.setState(.setCategories(categories))
         benefitsViewModel.segmentControl.stack.insertArrangedModel(allCategoriesButton, at: 0)
         allCategoriesButton.setMode(\.selected)
      case .updateSelectedCatefory(let id):
         benefitsViewModel.setState(.updateSelectedCategory(id))
         allCategoriesButton.setMode(\.normal)
      case .categoryAllSelected:
         allCategoriesButton.setMode(\.selected)
         benefitsViewModel.segmentControl.setState(.unselectAllButtons)
      }
   }
}
