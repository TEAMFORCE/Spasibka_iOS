//
//  CurrencyLabelDT.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 22.08.2022.
//

import StackNinja
import UIKit


class CurrencyLabelDT<Design: DSP>: StackNinja<SComboMRR<LabelModel, Spacer, ImageViewModel>>, Designable, ButtonTapAnimator {
   //
   var label: LabelModel { models.main }
   var currencyLogo: ImageViewModel { models.right2 }

   required init() {
      super.init()

      setAll {
         $0
            .set(Design.state.label.medium24)
            .text("0")
            .textColor(Design.color.iconInvert)
         $1
            .size(CGSize(width: 8, height: 8))
         $2
            .image(Design.icon.smallSpasibkaLogo)
            .imageTintColor(Design.color.iconInvert)
      }
      axis(.horizontal)
      padRight(20)
   }
}

class NewCurrencyLabelDT<Design: DSP>: StackNinja<SComboMRR<ImageViewModel, Spacer, LabelModel>>, Designable, ButtonTapAnimator {
   //
   var label: LabelModel { models.right2 }
   var currencyLogo: ImageViewModel { models.main }

   required init() {
      super.init()

      setAll {
         $0
            .image(Design.icon.smallSpasibkaLogo)
            .imageTintColor(Design.color.text)
            .size(.init(width: 17.45, height: 14))
         $1
            .size(CGSize(width: 0, height: 24))
         $2
            .set(Design.state.label.descriptionMedium16)
            .text("0")
      }
      axis(.horizontal)
   }
}


