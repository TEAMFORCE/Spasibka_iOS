//
//  BenefitsPurchaseFilterScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.01.2023.
//

import StackNinja

final class BenefitsPurchaseFilterScene<Asset: ASP>: 
   BaseFilterPopupScene<Asset, [SelectWrapper<OrderStatus>]>,  Scenarible {

   lazy var scenario = BenefitsPurchaseFilterScenario<Asset>(
      works: BenefitsPurchaseFilterWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: BenefitsPurchaseFilterScenarioEvents(
         didSelectFilterItemAtIndex: filterList.on(\.didSelectItemAtIndex),
         didApplyFilterPressed: applyFilterButton.on(\.didTap),
         didClearFilterPressed: clearFilterButton.on(\.didTap)
      )
   )
   
   // private 

   private lazy var filterList = TableItemsModel()
      .presenters(
         PurchaseHistoryFilterPresenter<Design>.presenter
      )
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()

   // Start

   override func start() {
      super.start()

      bodyStack
         .spacing(16)
         .arrangedModels(
            LabelModel()
               .set(Design.state.label.semibold20)
               .text(Design.text.status),
            filterList,
            Spacer(32)
         )

      closeButton.on(\.didTap, self) {
         $0.send(\.cancelled)
      }
      
      scenario.configureAndStart()
   }
}

enum BenefitsPurchaseFilterSceneState {
   case initial([SelectWrapper<OrderStatus>])
   
   case updateFilterItemAtIndex(item: SelectWrapper<OrderStatus>, index: Int)
   
   case applyFilter([SelectWrapper<OrderStatus>])
}

extension BenefitsPurchaseFilterScene: StateMachine {
   func setState(_ state: BenefitsPurchaseFilterSceneState) {
      switch state {
      case let .initial(value):
         filterList.items(value)
      case let .applyFilter(items):
         send(\.finishFiltered, items)
      case let .updateFilterItemAtIndex(item, index):
         filterList.updateItemAtIndex(item, index: index)
      }
   }
}

struct PurchaseHistoryFilterPresenter<Design: DSP> {
   static var presenter: CellPresenterWork<SelectWrapper<OrderStatus>, CheckMarkLabel<Design>> { .init { work in
      let item = work.in.item
      
      let cell = CheckMarkLabel<Design>()
         .setStates(
            .text(OrderStatusFactory<Design>.description(for: item.value)),
            .selected(item.isSelected)
         )
         .padding(.verticalOffset(7))
         .userInterractionEnabled(false)
      
      work.success(cell)
   }}
}
