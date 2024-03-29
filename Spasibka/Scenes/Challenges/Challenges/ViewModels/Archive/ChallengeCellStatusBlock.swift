//
//  ChallengeCellStatusBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.11.2022.
//

import StackNinja

final class ChallengeCellStatusBlock<Design: DSP>: StackModel, Designable {
   lazy var statusLabel = LabelModel()
      .set(Design.state.label.regular12)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusMini)
      .height(Design.params.buttonHeightMini)
      .backColor(Design.color.background)
      .padding(.horizontalOffset(8))

   lazy var dateLabel = LabelModel()
      .set(Design.state.label.regular12)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusMini)
      .height(Design.params.buttonHeightMini)
      .padding(.horizontalOffset(8))
      .backColor(Design.color.backgroundBrandSecondary)
      .borderColor(Design.color.iconContrast)
      .borderWidth(1)

   lazy var backImage = ImageViewModel()

   override func start() {
      super.start()

      alignment(.trailing)
      arrangedModels([
         statusLabel,
         Grid.xxx.spacer,
         dateLabel,
      ])

      backViewModel(backImage, inset: .init(top: 16, left: 16, bottom: 0, right: 0))
   }
}
