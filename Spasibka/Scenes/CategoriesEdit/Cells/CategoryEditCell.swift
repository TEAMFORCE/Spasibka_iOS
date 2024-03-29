//
//  CategoryEditCell.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.07.2023.
//

import StackNinja
import UIKit

final class EditCategoryCellPresenter<Design: DSP>: Eventable {
   struct Events: InitProtocol {
      var didTapDeleteItem: Any?
   }

   var events = EventsStore()

   var presenter: CellPresenterWork<CategoryData, EditCategoryCell<Design>> { .init { work in
      let item = work.in.item
//      let index = work.in.index
      let cell = EditCategoryCell<Design>()

      cell.label.text(item.name)
      if item.children?.isEmpty == true {
         cell.disclosureIcon.hidden(true)
         cell.configureSwipe()
      }
      cell.deleteButton.on(\.didTap, self) {
         $0.send(\.didTapDeleteItem, item)
      }

      work.success(cell)
   }}
}

final class EditCategoryCell<Design: DSP>: HStackModel {
   private(set) lazy var label = LabelModel()
      .set(Design.state.label.regular16)
      .textColor(Design.color.text)

   private(set) lazy var disclosureIcon = ImageViewModel()
      .size(.square(24))
      .image(Design.icon.tablerChevronRight, color: Design.color.iconContrast)

   private(set) lazy var deleteButton = ButtonModel()
      .set(Design.state.button.brandTransparent)
      .image(Design.icon.tablerTrash, color: Design.color.iconInvert)

   private lazy var bottomLayerModel = ViewModel()
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadius)
      .backColor(Design.color.backgroundBrand)
      .height(56)

   private lazy var topLayerModel = HStackModel()
      .backColor(Design.color.backgroundInfoSecondary)
      .alignment(.center)
      .padHorizontal(16)
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadius)
      .arrangedModels(
         label,
         disclosureIcon
      )

   private var topLayerRightConstraint: NSLayoutConstraint?

   required init() {
      super.init()

      alignment(.center)
      setNeedsStoreModelInView()

      backViewModel(
         bottomLayerModel,
         inset: .init(top: 4, left: 16, bottom: 4, right: 16)
      )

      bottomLayerModel
         .addModel(deleteButton) { anchors, superView in
            anchors
               .height(superView.heightAnchor)
               .width(superView.heightAnchor)
               .right(superView.rightAnchor)
         }
         .addModel(topLayerModel) { anchors, superView in
            anchors
               .width(superView.widthAnchor)
               .height(superView.heightAnchor)
               .centerY(superView.centerYAnchor)

            self.topLayerRightConstraint = anchors.right(superView.rightAnchor).constraint()
         }
   }

   func configureSwipe() {
      let swipe = UISwipeGestureRecognizer()
      swipe.cancelsTouchesInView = true
      swipe.delaysTouchesBegan = false
      swipe.direction = .left
      swipe.addTarget(self, action: #selector(swipeAction))
      view.addGestureRecognizer(swipe)
      topLayerModel.view
         .startTapGestureRecognize()
         .on(\.didTap, self) {
            $0.restoreCell()
         }
   }

   @objc private func swipeAction() {
      topLayerModel.cancelToucherForAllGestures(true)
      UIView.animate(withDuration: 0.12) {
         self.topLayerRightConstraint?.constant = -56
         self.view.layoutIfNeeded()
      }
   }

   private func restoreCell() {
      UIView.animate(withDuration: 0.12) {
         self.topLayerRightConstraint?.constant = 0
         self.view.layoutIfNeeded()
      } completion: { [weak self] _ in
         self?.topLayerModel.cancelToucherForAllGestures(false)
      }
   }
}
