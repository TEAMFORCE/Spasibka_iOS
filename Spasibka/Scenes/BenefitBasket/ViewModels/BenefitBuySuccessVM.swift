//
//  BenefitBuySuccessVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.02.2023.
//

import StackNinja

final class BenefitBuySuccessVM<Asset: ASP>: StackModel, Assetable {
   lazy var eventer = BenefitBasketCellPresenter<Design>()

   private lazy var buyBenefitsSuccessIllustration = ImageViewModel()
      .image(Design.icon.buyBenefitsSuccessIllustration)

   private lazy var buyButton = Design.button.default
      .set(Design.state.button.default)
      .title(Design.text.toMain)
      .on(\.didTap) {
         Asset.router?.popToRoot()
      }

   override func start() {
      super.start()

      backColor(Design.color.background)
      padding(.init(top: 80, left: 16, bottom: 32, right: 16))
      cornerRadius(Design.params.cornerRadiusBig)
      cornerCurve(.continuous)

      arrangedModels(
         LabelModel()
            .set(Design.state.label.semibold20)
            .text(Design.text.successfulOrder)
            .centeredX(),
         Spacer(32),
         buyBenefitsSuccessIllustration,
         Spacer(),
         buyButton
      )
   }
}
