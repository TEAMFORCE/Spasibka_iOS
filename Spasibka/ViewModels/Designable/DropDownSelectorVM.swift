//
//  DropDownSelectorVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 25.07.2023.
//

import StackNinja

final class DropDownSelectorVM<Design: DSP>: StackModel, Designable, Eventable {
   struct Events: InitProtocol {
      var didSelectItemAtIndex: Int?
   }

   var events = EventsStore()

   // MARK: - View models

   private lazy var titleLabel = LabelModel()
      .set(Design.state.label.descriptionRegular14)
      .textColor(Design.color.text)

   private lazy var titleIcon = ImageViewModel()
      .image(Design.icon.arrowDropDownLine)
      .size(.square(24))

   private lazy var titleWrapper = Wrapped2X(titleLabel, titleIcon)
      .height(52)
      .alignment(.center)

   private lazy var tableModel = TableItemsModel()
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()
      .presenters(itemPresenter)
      .cornerCurve(.continuous)
      .on(\.didSelectItemAtIndex, self) {
         $0.send(\.didSelectItemAtIndex, $1)
         $0.setState(.selectIndex($1))
         $0.collapse()
      }

   private lazy var tableWrapper = tableModel.toped()
      .padBottom(16)
      .hidden(true)

   // MARK: - Private vars

   private var items: [String] = []
   private var isExpanded = false

   override func start() {
      super.start()

      arrangedModels(
         titleWrapper,
         tableWrapper
      )
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadiusMini)
      borderColor(Design.color.iconMidpoint)
      borderWidth(1)
      padHorizontal(16)

      titleWrapper.view
         .startTapGestureRecognize()
         .on(\.didTap, self) {
            $0.isExpanded = !$0.isExpanded
            if $0.isExpanded {
               $0.expand()
            } else {
               $0.collapse()
            }
         }
   }
}

extension DropDownSelectorVM: StateMachine {
   enum ModelState {
      case titleText(String)
      case items([String])
      case selectIndex(Int)
   }

   func setState(_ state: ModelState) {
      switch state {
      case let .titleText(text):
         titleLabel.text(text)
      case let .items(items):
         self.items = items
         tableModel.items(items)
      case let .selectIndex(index):
         if let text = items[safe: index] {
            setState(.titleText(text))
         }
      }
   }
}

private extension DropDownSelectorVM {
   func expand() {
      isExpanded = true
      tableWrapper.hiddenAnimated(false, duration: 0.2)
      titleIcon.image(Design.icon.arrowDropUpLine)
   }

   func collapse() {
      isExpanded = false
      tableWrapper.hiddenAnimated(true, duration: 0.2)
      titleIcon.image(Design.icon.arrowDropDownLine)
   }
}

private extension DropDownSelectorVM {
   var itemPresenter: CellPresenterWork<String, StackModel> { .init { work in
      let type = work.unsafeInput

      let label = LabelModel()
         .set(Design.state.label.regular16)
         .text(type.item)
         .textColor(Design.color.text)

      let cell = StackModel()
         .spacing(Grid.x12.value)
         .axis(.horizontal)
         .alignment(.center)
         .arrangedModels([
            label,
            Spacer(),
         ])
         .height(40)

      work.success(cell)
   }}
}
