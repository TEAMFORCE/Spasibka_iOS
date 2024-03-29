//
//  TripleStackRoundedNavBarModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 29.11.2023.
//

import StackNinja
import UIKit

protocol NavBarStackModelProtocol {
   var backButton: ButtonModel { get }
   var titleLabel: LabelModel { get }
   var menuButton: ButtonModel { get }
   var purchaseHistoryButton: ButtonModel { get }
   var basketButton: ButtonModel { get }
   var buttonSpacer: Spacer { get }
   func secondaryButtonHidden(_ value: Bool)
}

typealias NavBarProtocol = HStackModel & NavBarStackModelProtocol

final class BrandNavBarStackModel<Design: DSP>: NavBarProtocol {
   let backButton = ButtonModel()
      .image(Design.icon.navBarBackButton)
      .size(.square(24))

   let titleLabel = LabelModel()
      .set(Design.state.label.labelRegular16)
      .alignment(.center)
      .textColor(Design.color.text)
   
   let basketButton = ButtonModel()
      .size(.square(24))
      .image(Design.icon.basket)
      .tint(Design.color.text)

   let purchaseHistoryButton = ButtonModel()
      .size(.square(24))
      .image(Design.icon.heart)
      .tint(Design.color.text)
   
   let menuButton = ButtonModel()
      .size(.square(24))

   let buttonSpacer = Spacer(24)
      .hidden(true)

   override func start() {
      super.start()

      arrangedModels(backButton, titleLabel, menuButton, buttonSpacer)
      distribution(.equalCentering)
   }

   func secondaryButtonHidden(_ value: Bool) {
      menuButton.hidden(value)
      buttonSpacer.hidden(!value)
   }
}

final class BenefitNavBarStackModel<Design: DSP>: NavBarProtocol {
   let backButton = ButtonModel()
      .image(Design.icon.navBarBackButton)
      .size(.square(24))

   let titleLabel = LabelModel()
      .set(Design.state.label.labelRegular16)
      .alignment(.center)
      .textColor(Design.color.text)

   let basketButton = ButtonModel()
      .size(.square(24))
      .image(Design.icon.basket.withTintColor(Design.color.text))
      .tint(Design.color.text)
   
   let menuButton = ButtonModel()
      .size(.square(24))

   let purchaseHistoryButton = ButtonModel()
      .size(.square(24))
      .image(Design.icon.garage)
//      .tint(Design.color.text)
   
   let buttonSpacer = Spacer(24)
      .hidden(true)

   override func start() {
      super.start()
      
      arrangedModels(backButton, titleLabel, Grid.xxx.spacer, purchaseHistoryButton, Spacer(24), basketButton, buttonSpacer)
//      distribution(.equalCentering)
      distribution(.fill)
   }

   func secondaryButtonHidden(_ value: Bool) {
      purchaseHistoryButton.hidden(value)
      basketButton.hidden(value)
      buttonSpacer.hidden(!value)
   }
}

extension UIImage {
   func rotated(byDegrees degrees: CGFloat) -> UIImage {
      // Calculate the size of the rotated view's containing box for our drawing space
      let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
      let t = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
      rotatedViewBox.transform = t
      let rotatedSize = rotatedViewBox.frame.size

      // Create the bitmap context
      UIGraphicsBeginImageContext(rotatedSize)
      guard let bitmap = UIGraphicsGetCurrentContext() else { return .init() }

      // Move the origin to the middle of the image so we will rotate and scale around the center.
      bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)

      // Rotate the image context
      bitmap.rotate(by: degrees * CGFloat.pi / 180)

      // Now, draw the rotated/scaled image into the context
      draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))

      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      return newImage ?? .init()
   }
}


extension AnimatedHeaderNavbarBodyFooterStack {
   typealias State = StackState
   typealias State2 = ViewState
}

final class AnimatedHeaderNavbarBodyFooterStack<Asset: AssetProtocol>: VStackModel, HeaderBodyFooterStackProtocol,
   Assetable
{
   private(set) lazy var headerStack = StackModel(
      .axis(.vertical),
      .alignment(.fill),
      .distribution(.fill),
      .backColor(Design.color.backgroundBrand)
   )

   private(set) lazy var navBar = BrandNavBarStackModel<Design>()
      .padding(.init(top: -16, left: 16, bottom: 16, right: 16))
      .backColor(Design.color.background)

   private(set) lazy var bodyStack = StackModel(
      .axis(.vertical),
      .alignment(.fill),
      .distribution(.fill)
   )

   private(set) lazy var footerStack = StackModel(
      .axis(.vertical),
      .alignment(.fill),
      .distribution(.fill)
   )

   override func start() {
      super.start()

      axis(.vertical)
      alignment(.fill)
      distribution(.fill)
      arrangedModels(
         headerStack,
         navBar,
         bodyStack.arrangedModels(Spacer()),
         footerStack.arrangedModels(Spacer(1))
      )
      headerStack.frontViewModel(
         StackModel()
            .height(Design.params.sceneCornerRadius * 2)
            .backColor(Design.color.background)
            .cornerCurve(.continuous)
            .cornerRadius(Design.params.sceneCornerRadius)
            .clipsToBound(true)
            .maskToBounds(true)
            .maskedCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner])
      ) {
         $0.fitToBottom($1, offset: -Design.params.sceneCornerRadius)
      }

      navBar.backButton.on(\.didTap) {
         Asset.router?.pop()
      }
      navBar.menuButton.on(\.didTap) {
         // route here?
      }
   }
}
