//
//  NewBenefitCell.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.02.2024.
//

import StackNinja
import UIKit

final class NewBenefitCell<Design: DSP>: StackModel, Designable, Eventable {
   typealias Events = BenefitCellEvent
   var events: EventsStore = .init()
   
   private(set) lazy var  icon = ImageViewModel()
      .contentMode(.scaleAspectFill)
      .backColor(Design.color.backgroundBrand)
      .size(.square(164.aspected))
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)

   private(set) lazy var  benefitName = LabelModel()
      .set(Design.state.label.descriptionRegular10)
   

   let priceModel = NewCurrencyLabelDT<Design>()
      .setAll { image, _, label in
         label
            .font(Design.font.descriptionMedium12)
            .text("")
            .numberOfLines(2)
         image
            .image(Design.icon.smallSpasibkaLogo)
            .imageTintColor(Design.color.text)
            .size(.init(width: 12.47, height: 10))
      }
      .height(14)
      .spacing(2)

   required init() {
      super.init()
      setNeedsStoreModelInView()

      axis(.vertical)
      alignment(.leading)
      arrangedModels([
         icon,
         Spacer(8),
         benefitName,
         Spacer(2),
         priceModel
      ])
      backColor(Design.color.background)
      
      view.startTapGestureRecognize()
      view.on(\.didTap, self) {
         $0.send(\.cellPressed, 1)
      }
   }
}
