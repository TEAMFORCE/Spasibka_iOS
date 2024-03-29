//
//  BenefitsPurchaseHistoryScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 05.02.2023.
//

import CoreGraphics
import StackNinja

struct BenefitsPurchaseHistoryParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = ModalDoubleStackModel<Asset>
   }

   struct InOut: InOutParams {
      typealias Input = Market
      typealias Output = Void
   }
}

final class BenefitsPurchaseHistoryScene<Asset: ASP>:
   BaseParamsScene<BenefitsPurchaseHistoryParams<Asset>>, Scenarible
{
   lazy var scenario = BenefitsPurchaseHistoryScenario<Asset>(
      works: BenefitsPurchaseHistoryWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: BenefitsPurchaseHistoryEvents(
         saveInput: on(\.input),
         didSelectItemAtIndex: historyList.on(\.didSelectItemAtIndex),
         didTapFilterButton: filterButton.on(\.didTap),
         didApplyFilter: Out<[SelectWrapper<OrderStatus>]>()
      )
   )

   private lazy var historyList = TableItemsModel()
      .presenters(
         SpacerPresenter.presenter,
         PurchasedBenefitCell<Design>.presenter
      )
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()

   private lazy var benefitsPurchaseFilterModel = BenefitsPurchaseFilterScene<Asset>({
      $0
         .on(\.finishFiltered, self) {
            if $1.isEmpty {
               $0.filterButton.setMode(\.normal)
            } else {
               $0.filterButton.setMode(\.selected)
            }
            $0.scenario.events.didApplyFilter.sendAsyncEvent($1)
            self.bottomPopupPresenter.setState(.hide)
         }
         .on(\.cancelled, self) {
            $0.bottomPopupPresenter.setState(.hide)
         }
   })

   private lazy var filterButton = Design.model.common.filterButton

   private lazy var bottomPopupPresenter = BottomPopupPresenter()

   private lazy var hereIsEmpty = Design.model.common.hereIsEmptySpaced
   private lazy var activityIndicator = Design.model.common.activityIndicatorSpaced

   override func start() {
      mainVM.title
         .text(Design.text.orderHistory)
      mainVM.closeButton
         .title(Design.text.closeButton)
         .on(\.didTap, self) {
            $0.dismiss()
         }

      mainVM.bodyStack
         .arrangedModels(
            activityIndicator,
            hereIsEmpty,
            historyList,
            Spacer()
         )
      mainVM
         .addModel(filterButton) { anchors, superview in
            anchors.fitToBottomRight(superview, offset: 48, sideOffset: 16)
         }

      setState(.initial)
      scenario.configureAndStart()
   }
}

enum BenefitsPurchaseHistoryState {
   case initial
   case presentOrders([CartItem])
   case presentOrder((Int, Market))

   case presentFilter
}

extension BenefitsPurchaseHistoryScene: StateMachine {
   func setState(_ state: BenefitsPurchaseHistoryState) {
      switch state {
      case .initial:
         filterButton.hidden(true)
         hereIsEmpty.hidden(true)
      case let .presentOrders(orders):
         activityIndicator.hidden(true)
         hereIsEmpty.hidden(!orders.isEmpty)

         historyList.items(orders + [SpacerItem(80)])
         filterButton.hidden(false)
      case let .presentOrder(value):
         Asset.router?.route(.presentModallyOnPresented(.automatic),
                             scene: \.benefitDetails,
                             payload: value)
         break
      case .presentFilter:
         benefitsPurchaseFilterModel.scenario.configureAndStart()

         bottomPopupPresenter.setState(.presentWithAutoHeight(model: benefitsPurchaseFilterModel,
                                                              onView: vcModel?.view.rootSuperview))
      }
   }
}
