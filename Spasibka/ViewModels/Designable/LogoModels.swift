//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.08.2022.
//

import StackNinja

protocol IconUpdatable {
   func updateIcon()
}

final class SmallLogo<Design: DesignProtocol>: ImageViewModel, Designable, IconUpdatable {
   typealias State = ImageViewState

   required init() {
      super.init()

      image(Design.icon.smallLogo)
      contentMode(.scaleAspectFit)
   }

   func updateIcon() {
      image(Design.icon.smallLogo)
   }
}

final class LoginLogo<Design: DesignProtocol>: ImageViewModel, Designable, IconUpdatable {
   required init() {
      super.init()

      image(Design.icon.loginLogo)
      contentMode(.scaleAspectFit)
   }

   func updateIcon() {
      image(Design.icon.loginLogo)
   }
}

final class MenuLogo<Design: DesignProtocol>: ImageViewModel, Designable, IconUpdatable {
   required init() {
      super.init()

      image(Design.icon.menuLogo)
      contentMode(.scaleAspectFit)
   }

   func updateIcon() {
      image(Design.icon.menuLogo)
   }
}

final class SpasibkaLogo<Design: DesignProtocol>: BaseViewModel<PaddingImageView>, Stateable {
   typealias State = ImageViewState

   override func start() {
      image(Design.icon.smallSpasibkaLogo)
      contentMode(.scaleAspectFit)

      backColor(Design.color.transparent)
   }
}
