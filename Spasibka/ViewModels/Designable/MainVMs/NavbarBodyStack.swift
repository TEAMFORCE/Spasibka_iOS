//
//  StackRoundedNavBarModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 30.11.2023.
//

import StackNinja
import UIKit

class NavbarBodyStack<Asset: AssetProtocol, M: NavBarScenePresenting>: BaseNavbarStack<Asset, M> {}

class NavbarBodyFooterStack<Asset: AssetProtocol, M: NavBarScenePresenting>: BaseNavbarStack<Asset, M> {
   private(set) lazy var footerStack = StackModel()
      .set(Design.state.stack.bottomPanel)
      .backColor(Design.color.background)

   override func start() {
      super.start()

      let footerSetup = VStackModel(footerStack)
      addArrangedModel(footerSetup)
   }
}
