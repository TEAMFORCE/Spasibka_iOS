//
//  MarketFilterScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.01.2023.
//

import StackNinja

struct MarketFilterParams: Codable {
   var categoryId: Int?

   let fromPrice: Int?
   let toPrice: Int?

   let isExpiresChecked: Bool

   var contain: String?
}

struct MarketFilterEvents: InitProtocol {
   var cancelled: Void?
   var finishFiltered: MarketFilterParams?
}

final class MarketFilterScene<Asset: ASP>: BaseFilterPopupScene<Asset, MarketFilterParams>, Scenarible {

   lazy var scenario = MarketFilterScenario<Asset>(
      works: MarketFilterWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: MarketFilterScenarioEvents(
         initializeWithFilters: Out<MarketFilterPopupInput>(),
         didSelectFilterItemAtIndex: filterList.on(\.didSelectItemAtIndex),
         didFromPriceInput: fromPriceField.on(\.didEditingChanged),
         didToPriceInput: toPriceField.on(\.didEditingChanged),
         didExpiresChecked: expiresSwitcher.on(\.turned),
         didApplyFilterPressed: applyFilterButton.on(\.didTap),
         didClearFilterPressed: clearFilterButton.on(\.didTap)
      )
   )

   private var fromPriceField: TextFieldModel { fromToPriceFields.models.main }
   private var toPriceField: TextFieldModel { fromToPriceFields.models.right }

   private var expiresSwitcher: Switcher { expiresLabelSwitcher.models.right.subModel }

   // Private
   private lazy var fromToPriceFields = Stack<TextFieldModel>.R<TextFieldModel>.Ninja()
      .setAll { fromField, toField in
         fromField
            .set(Design.state.textField.default)
            .placeholder(Design.text.from)
            .onlyDigitsMode()
         toField
            .set(Design.state.textField.default)
            .placeholder(Design.text.to)
            .onlyDigitsMode()
      }
      .distribution(.fillEqually)
      .spacing(12)

   private lazy var expiresLabelSwitcher = LabelSwitcherXDT<Design>.switcherWith(text: Design.text.expires)
   
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
         .spacing(16)
         .arrangedModels(
            LabelModel()
               .set(Design.state.label.semibold20)
               .text(Design.text.category),
            filterList,
            Spacer(6),
            LabelModel()
               .set(Design.state.label.semibold20)
               .text(Design.text.price1),
            fromToPriceFields,
            //expiresLabelSwitcher,
            Spacer(32)
         )

      closeButton.on(\.didTap, self) {
         $0.send(\.cancelled)
      }
   }
}

enum MarketFilterSceneState {
   case initial(MarketFilterParams)
   case applyFilter(MarketFilterParams?)
   case setFilters(MarketFilterPopupInput)
   case updateFilters(MarketFilterPopupInput)
   case updateFilterItemAtIndex(item: (String, Bool), index: Int)
}

extension MarketFilterScene: StateMachine {
   func setState(_ state: MarketFilterSceneState) {
      switch state {
      case let .initial(value):
         fromPriceField.text(value.fromPrice?.toString ?? "")
         toPriceField.text(value.toPrice?.toString ?? "")
         expiresSwitcher.setState(value.isExpiresChecked ? .turnOn : .turnOff)
      case let .applyFilter(value):
         var categoryId: Int?
         var fromPrice: Int?
         var toPrice: Int?
         if let value = value {
            categoryId = value.categoryId
            fromPrice = value.fromPrice
            toPrice = value.toPrice
         }
         let filter = MarketFilterParams(
            categoryId: categoryId,
            fromPrice: fromPrice,
            toPrice: toPrice,
            isExpiresChecked: false,
            contain: nil)
         send(\.finishFiltered, filter)
      case .setFilters(let value):
         var items = value.categories.map{ ($0, false) }
         if let id = value.filterParams.categoryId, items.indices.contains(id-1) {
            items[id-1] = (value.categories[id-1], true)
         }
         let res = items.map(checkmarkInputFrom)
         filterList.items(res)
      case .updateFilters(let value):
         let items = value.categories.map { ($0, false) }
         let res = items.map(checkmarkInputFrom)
         filterList.items(res)
      case let .updateFilterItemAtIndex(item, index):
         filterList.updateItemAtIndex(
            checkmarkInputFrom(item),
            index: index
         )
      }
   }
   
   private func checkmarkInputFrom(_ value:(String, Bool)) -> CheckMarkLabelInput {
      CheckMarkLabelInput(
         text: value.0,
         isSelected: value.1,
         leftOffset: 0
      )
   }
}
