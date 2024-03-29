//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.08.2022.
//

import StackNinja

class TitleSubtitleX<Design: DesignProtocol>:
   StackNinja<SComboMR<LabelModel, LabelModel>>,
   Designable
{
   required init() {
      super.init()

      setMain {
         $0
            .set(Design.state.label.bold24)
            .alignment(.center)
      } setRight: {
         $0
            .set(Design.state.label.regular16)
            .alignment(.center)
            .textColor(Design.color.textSecondary)
      }
   }
}
