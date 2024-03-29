//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.08.2022.
//

import StackNinja

class TitleSubtitleY<Design: DesignProtocol>:
   StackNinja<SComboMD<LabelModel, LabelModel>>,
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
            .textColor(Design.color.textSecondary)
            .numberOfLines(0)
            .alignment(.center)
      }
   }
}

class TitleBodyY: Stack<LabelModel>.D<LabelModel>.Ninja {

   var title: LabelModel { models.main }
   var body: LabelModel { models.down }

   required init() {
      super.init()

      setMain {
         $0
            .numberOfLines(0)
            .alignment(.left)
      } setDown: {
         $0
            .numberOfLines(0)
            .alignment(.left)
      }
   }
}

class TitleBodyX: Stack<LabelModel>.R<LabelModel>.Ninja {

   var title: LabelModel { models.main }
   var body: LabelModel { models.right }

   required init() {
      super.init()

      setMain {
         $0
            .numberOfLines(0)
            .alignment(.left)
      } setRight: {
         $0
            .numberOfLines(0)
            .alignment(.left)
      }
   }
}
