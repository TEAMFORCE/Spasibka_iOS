//
//  CheckMarkModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.01.2023.
//

import Foundation
import StackNinja

final class CheckMarkModel<Design: DSP>: SelectableButton, Designable {
   override func start() {
      super.start()

      size(.square(24))
      cornerRadius(Design.params.cornerRadiusNano)
      cornerCurve(.continuous)
      borderWidth(1)

      super.onModeChanged(\.normal) {
         $0
            .image(nil)
            .backColor(Design.color.transparent)
            .borderColor(Design.color.iconMidpoint)
      }
      super.onModeChanged(\.selected) {
         $0
            .image(Design.icon.checkLine, color: Design.color.iconInvert)
            .backColor(Design.color.backgroundBrand)
            .borderColor(Design.color.backgroundBrand)
      }
      super.setMode(\.normal)
   }
}

extension CheckMarkModel: StateMachine {
   func setState(_ state: Bool) {
      setSelected(state)
   }
}
