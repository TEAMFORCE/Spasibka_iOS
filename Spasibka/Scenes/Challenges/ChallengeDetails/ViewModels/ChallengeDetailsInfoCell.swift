//
//  ChallengeDetailsInfoCell.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.11.2022.
//

import StackNinja

final class ChallengeDetailsInfoCell<Design: DSP>:
   Stack<ImageViewModel>.R<LabelModel>.R2<Spacer>.R3<LabelModel>.Ninja,
   Designable
{
   required init() {
      super.init()

      setAll { icon, title, _, status in
         icon.size(.square(24))
         title.set(Design.state.label.regular14)
         status.set(Design.state.label.regular12Secondary)
      }
      .backColor(Design.color.background)
      .height(Design.params.buttonHeight)
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadiusSmall)
      .shadow(Design.params.cellShadow)
      .spacing(12)
      .alignment(.center)
      .padding(.horizontalOffset(16))
   }
}
