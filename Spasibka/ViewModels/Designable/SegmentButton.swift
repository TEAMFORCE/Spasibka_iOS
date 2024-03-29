//
//  SegmentButton.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.09.2023.
//

import StackNinja

final class SegmentButton<Design: DSP>: ModableButton, Designable {
   override func start() {
      super.start()

      font(Design.font.semibold14)
      height(38)
      onModeChanged(\.normal) { [weak self] in
         self?
            .backColor(Design.color.backgroundInfoSecondary)
            .textColor(Design.color.text)
      }
      onModeChanged(\.selected) { [weak self] in
         self?
            .backColor(Design.color.backgroundBrand)
            .textColor(Design.color.textInvert)
      }
      setMode(\.normal)
   }
}
