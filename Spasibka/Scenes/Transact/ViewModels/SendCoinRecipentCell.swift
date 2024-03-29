//
//  SendCoinRecipentCell.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 03.09.2022.
//

import StackNinja

final class SendCoinRecipentCell<Design: DSP>:
   Stack<ImageViewModel>.R<LabelModel>.D<LabelModel>.R2<CurrencyLabelDT<Design>>.Ninja
{
   required init() {
      super.init()

      setAll { avatar, userName, nickName, amount in
         avatar
            .size(.square(44))
            .cornerCurve(.continuous).cornerRadius(44 / 2)
            .contentMode(.scaleAspectFill)
         userName
            .set(Design.state.label.medium16)
            .alignment(.left)
         nickName
            .set(Design.state.label.regular12Secondary)
            .alignment(.left)
         amount.label
            .height(Grid.x32.value)
            .set(Design.state.label.bold32)
            .textColor(Design.color.textError)
         amount.currencyLogo
            .width(22)
      }
      .padding(.outline(Grid.x16.value))
      .backColor(Design.color.background)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
      .shadow(Design.params.cellShadow)
      .borderColor(.black)
      .alignment(.center)
      .distribution(.equalSpacing)
   }
}
