//
//  VKLoginButton.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 05.09.2023.
//

import StackNinja

final class VKLoginButton<Design: DSP>: ButtonModel {
   override func start() {
      super.start()

      set(Design.state.button.default)
      backColor(Design.color.brandVKontakte)
      title(Design.text.loginViaVK)
      image(Design.icon.logoVKontakteButton, color: Design.color.constantWhite)
      padding(.init(top: 12, left: 12, bottom: 12, right: 12))
   }
}
