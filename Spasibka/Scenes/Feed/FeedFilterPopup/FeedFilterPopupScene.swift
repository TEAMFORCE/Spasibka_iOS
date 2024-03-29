//
//  FeedFilterPopupScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.07.2023.
//

import StackNinja

final class FeedFilterPopupScene<Asset: ASP>: BaseFilterPopupScene<Asset, [SelectableEventFilter]>, Scenarible {
   lazy var scenario = FeedFilterPopupScenario<Asset>(
      works: FeedFilterPopupWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: FeedFilterPopupScenarioEvents(
         initializeWithFilter: Out<[SelectableEventFilter]>(),
         didSelectFilterItemAtIndex: filterList.on(\.didSelectItemAtIndex),
         didApplyFilterPressed: applyFilterButton.on(\.didTap),
         didClearFilterPressed: clearFilterButton.on(\.didTap)
      )
   )

   // private

   private lazy var filterList = TableItemsModel()
      .presenters(
         CheckMarkLabelPresenter<Design>.presenter
      )
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()
      .maxHeight(200.aspected)

   // Start

   override func start() {
      super.start()

      bodyStack
         .spacing(12)
         .arrangedModels(
            LabelModel()
               .set(Design.state.label.semibold20)
               .text(Design.text.categories),
            filterList,
            Spacer(32)
         )

      closeButton.on(\.didTap, self) {
         $0.send(\.cancelled)
      }

      scenario.configureAndStart()
   }
}

enum FeedFilterPopupState {
   case initial([SelectableEventFilter])

   case updateFilterItemAtIndex(item: SelectableEventFilter, index: Int)

   case applyFilter([SelectableEventFilter])
}

extension FeedFilterPopupScene: StateMachine {
   func setState(_ state: FeedFilterPopupState) {
      switch state {
      case let .initial(value):
         let items = value.map(checkmarkInputFrom)
         filterList.items(items)

      case let .applyFilter(value):
         let items = value.map(checkmarkInputFrom)
         filterList.items(items)
         send(\.finishFiltered, value)

      case let .updateFilterItemAtIndex(item, index):
         filterList.updateItemAtIndex(
            checkmarkInputFrom(item),
            index: index
         )
      }
   }

   private func checkmarkInputFrom(_ value: SelectableEventFilter) -> CheckMarkLabelInput {
      CheckMarkLabelInput(
         text: value.value.name,
         isSelected: value.isSelected,
         leftOffset: 0
      )
   }
}
