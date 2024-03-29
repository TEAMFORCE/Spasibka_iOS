//
//  ChallengeChainCardInfoVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 31.01.2024.
//

import StackNinja
import UIKit

final class CardInfoHeaderVM<Design: DSP>: M<ImageViewModel>.R<LabelModel>.Ninja {
   required init() {
      super.init()

      setAll { image, title in
         image
            .size(.square(24))
         title
            .padTop(4)
            .set(Design.state.label.descriptionRegular10)
            .numberOfLines(0)
            .lineSpacing(8)
            .alignment(.left)
            .textColor(Design.color.textSecondary)
            .lineBreakMode(.byCharWrapping)
            .padRight(12)
      }
      spacing(6)
      minHeight(40)
      alignment(.top)
   }

   func image(_ image: UIImage) {
      models.main.image(image)
   }

   func text(_ text: String) {
      models.right.text(text.replacingOccurrences(of: " ", with: "\n"))
   }
   func textUnedited(_ text: String) {
      models.right.numberOfLines(0)
      models.right.lineBreakMode(.byWordWrapping)
      models.right.text(text)
   }
}

final class ChallengeChainCardInfoVM<Design: DSP>:
   M<CardInfoHeaderVM<Design>>
   .D<LabelModel>
   .Ninja
{
   var headerVM: CardInfoHeaderVM<Design> { models.main }
   var caption: LabelModel { models.down }

   required init() {
      super.init()

      setAll { _, caption in
         caption
            .set(Design.state.label.descriptionRegular12)
      }
      spacing(26)
      padding(.outline(12))
      padRight(4)
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadiusSmall)
      shadow(Design.params.cellShadow)
      backColor(Design.color.background)
   }
}
