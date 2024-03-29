//
//  LabelSwitcherPanel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.07.2023.
//

import StackNinja
import CoreGraphics

final class LabelSwitcherPanel<Design: DSP>: LabelSwitcherX {
   override func start() {
      super.start()

      backColor(Design.color.background)
      padHorizontal(0)
      padVertical(0)
      height(24)

      switcher.view.onTintColor = Design.color.iconSecondary
      switcher.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      label
         .set(Design.state.label.labelRegular14)
   }
}
