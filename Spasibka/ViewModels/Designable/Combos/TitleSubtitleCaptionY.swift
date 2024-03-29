//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.08.2022.
//

import StackNinja

class TitleSubtitleCaptionY<Design: DesignProtocol>:
   StackNinja<SComboMDD<LabelModel, LabelModel, LabelModel>>,
   Designable
{
   required init() {
      super.init()
      
      setMain {
         $0
            .set(Design.state.label.bold24)
            .numberOfLines(0)
            .alignment(.center)
      } setDown: {
         $0
            .set(Design.state.label.regular16)
            .numberOfLines(0)
            .alignment(.center)
            .padTop(Design.params.titleSubtitleOffset)
            .textColor(Design.color.textSecondary)
      } setDown2: {
         $0
            .set(Design.state.label.regular12)
            .numberOfLines(0)
            .alignment(.center)
            .padTop(Design.params.titleSubtitleOffset)
      }
   }
}
