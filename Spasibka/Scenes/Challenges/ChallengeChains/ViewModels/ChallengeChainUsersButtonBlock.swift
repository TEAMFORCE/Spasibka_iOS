//
//  ChallengeChainUsersButtonBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.02.2024.
//

import StackNinja

final class ChallengeChainUsersButtonBlock<Asset: ASP>: VStackModel, Assetable {
   private(set) lazy var backButton = ButtonModel()
      .image(Design.icon.navBarBackButton, color: Design.color.constantWhite)
      .on(\.didTap) {
         Asset.router?.pop()
      }
   private(set) lazy var button = Design.button.brandSecondaryRound
      .backColor(Design.color.constantBlack.withAlphaComponent(0.5))
      .size(.square(40))
      .cornerRadius(40 / 2)
      .image(Design.icon.usersThree, color: Design.color.constantWhite)

   override func start() {
      super.start()

      arrangedModels(backButton, Spacer(), button)
   }
}
