//
//  CategoryTagModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.08.2023.
//

import StackNinja

final class CategoriesTagsScrollModel<Design: DSP>: ScrollStackedModelX, StateMachine {
   func setState(_ models: [UIViewModel]) {
      arrangedModels(models)
      hidden(models.isEmpty)
      spacing(4)
      padding(.bottom(16))
   }
}

final class CategoryTagModel<Design: DSP>: HStackModel {
   let label = LabelModel()
      .set(Design.state.label.regular12)
      .textColor(Design.color.textInfo)
      .kerning(-0.1)

   override func start() {
      super.start()

      arrangedModels(label)
      alignment(.center)

      height(24)

      padding(.horizontalOffset(8))
      backColor(Design.color.backgroundInfoSecondary)
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadiusMini)
      borderColor(Design.color.iconInvert)
   }

   @discardableResult
   func text(_ value: String, inverted: Bool = false) -> Self {
      label.text(value)
      if inverted {
         backColor(Design.color.transparent)
         label.textColor(Design.color.textInvert)
         borderWidth(1)
         borderColor(Design.color.iconInvert)
      } else {
         backColor(Design.color.transparent)
         label.textColor(Design.color.text)
         borderWidth(1)
         borderColor(Design.color.iconContrast)
      }
      return self
   }
}
