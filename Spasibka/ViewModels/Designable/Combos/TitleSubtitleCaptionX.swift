//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.08.2022.
//

import StackNinja

class TitleSubtitleCaptionX<Design: DesignProtocol>:
   StackNinja<SComboMRR<LabelModel, LabelModel, LabelModel>>,
   Designable
{

   required init() {
      super.init()
      
      setMain {
         $0
            .set(Design.state.label.bold24)
            .set(.numberOfLines(0))
            .set(.alignment(.center))
      } setRight: {
         $0
            .set(Design.state.label.regular16)
            .set(.numberOfLines(0))
            .set(.alignment(.center))
            .set(.textColor(Design.color.textSecondary))
      } setRight2: {
         $0
            .set(Design.state.label.regular12)
            .set(.numberOfLines(0))
            .set(.alignment(.center))
      }
   }
}
