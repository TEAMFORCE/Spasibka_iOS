//
//  CountSelectorModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 13.02.2024.
//

import StackNinja

final class CountSelectorVM<Design: DSP>: Stack<ButtonModel>.R<LabelModel>.R2<ButtonModel>.Ninja, Designable {
   var plusButton: ButtonModel { models.right2 }
   var minusButton: ButtonModel { models.main }
   var quantity: LabelModel { models.right }

   private var label: LabelModel { models.right }

   required init() {
      super.init()

      setAll { minusButton, label, plusButton in
         plusButton
            .title("+")
            .tint(Design.color.textBrand)
            .font(Design.font.descriptionMedium12)
            .backColor(Design.color.backgroundBrandSecondary)
            .cornerRadius(6)
            .cornerCurve(.continuous)
            .size(.init(width: 19, height: 24))
         minusButton
            .title("-")
            .tint(Design.color.textBrand)
            .font(Design.font.descriptionMedium12)
            .backColor(Design.color.backgroundBrandSecondary)
            .cornerRadius(6)
            .cornerCurve(.continuous)
            .size(.init(width: 19, height: 24))
         label
            .set(Design.state.label.descriptionMedium12)
            .text("0")
            .textColor(Design.color.textContrastSecondary)
            .alignment(.center)
            .backColor(Design.color.infoSecondary)
            .cornerRadius(6)
            .cornerCurve(.continuous)
            .height(24)
            .minWidth(29)
      }
      .spacing(3)
      .minWidth(74)
      .distribution(.fillEqually)
      .alignment(.center)
   }
}
