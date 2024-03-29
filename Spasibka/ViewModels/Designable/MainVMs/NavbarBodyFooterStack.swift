//
//  NavbarBodyFooterStack.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 06.02.2024.
//

import StackNinja

protocol NavBarScenePresenting {}
enum PresentBottomScheet: NavBarScenePresenting {}
enum PresentPush: NavBarScenePresenting {}
enum PresentInitial: NavBarScenePresenting {}

class BaseNavbarStack<Asset: AssetProtocol, M: NavBarScenePresenting>: VStackModel, Assetable {
   enum PresentingType {
      case initial
      case bottomSheet
      case push
   }

   let presentingType: PresentingType = {
      if M.self is PresentBottomScheet.Type {
         return .bottomSheet
      } else if M.self is PresentPush.Type {
         return .push
      } else {
         return .initial
      }
   }()

   private(set) lazy var navBar: NavBarProtocol = BrandNavBarStackModel<Design>()
      .backColor(Design.color.background)
   private(set) lazy var bodyStack = StackModel()
      .backColor(Design.color.background)

   override func start() {
      super.start()
      configureNavBarBackButton()
      setupStackArrangement()
      handleNavBarBackButtonTap()
   }
   
   func setBenefitNavBar() {
      navBar = BenefitNavBarStackModel<Design>().backColor(Design.color.background)
      //configureNavBarBackButton()
      navBar.titleLabel
         .set(Design.state.label.descriptionMedium20)
      setupStackArrangement()
      handleNavBarBackButtonTap()
   }

   private func configureNavBarBackButton() {
      switch presentingType {
      case .initial:
         navBar.arrangedModels(navBar.backButton, navBar.titleLabel, navBar.menuButton, navBar.buttonSpacer)
         navBar.titleLabel
            .set(Design.state.label.descriptionMedium20)
      case .bottomSheet:
         navBar.arrangedModels(navBar.menuButton, navBar.titleLabel, navBar.buttonSpacer, navBar.backButton)
         navBar.backButton
            .image(Design.icon.xCross)
      case .push:
         navBar.arrangedModels(navBar.backButton, navBar.titleLabel, navBar.menuButton, navBar.buttonSpacer)
         navBar.backButton
            .image(Design.icon.navBarBackButton)
      }
   }

   private func setupStackArrangement() {
      let (spacer, navBarTopOffset) = {
         switch presentingType {
         case .initial:
            navBar.backButton
               .hidden(true)
            return (topSafeAreaInset(), -16.0)
         case .bottomSheet:
            return (1, 24.0)
         case .push:
            return (topSafeAreaInset(), -16.0)
         }
      }()
      
      arrangedModels(
         Spacer(spacer),
         VStackModel(
            navBar.padding(.init(top: navBarTopOffset, left: 16, bottom: 16, right: 16)),
            bodyStack
         )
         .backColor(Design.color.background)
         .cornerRadius(Design.params.sceneCornerRadius)
         .cornerCurve(.continuous)
         .clipsToBound(true)
         .maskToBounds(true)
         .maskedCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner])
      )
   }

   private func handleNavBarBackButtonTap() {
      navBar.backButton.on(\.didTap) {
         switch self.presentingType {
         case .initial:
            break
         case .push:
            Asset.router?.pop()
         case .bottomSheet:
            Asset.router?.dismissPresented()
         }
      }
   }
}
