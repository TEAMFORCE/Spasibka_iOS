//
//  NewHeaderAnimatedSceneProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 29.01.2024.
//

import StackNinja
import UIKit

protocol NewHeaderAnimatedSceneProtocol: SceneModel, Assetable
   where Asset: AssetProtocol, MainViewModel: AnimatedHeaderNavbarBodyFooterStack<Asset>
{
   associatedtype HeaderViewModel: ViewModelProtocol

   var headerViewModel: HeaderViewModel { get }
   var headerBrightness: ColorBrightnessStyle { get set }

   var minHeaderHeight: CGFloat { get }
   var maxHeaderHeight: CGFloat { get }
   
   var isNavBarEnabled: Bool { get }

   var animationDuration: TimeInterval { get }

   var headerHeightConstraint: NSLayoutConstraint? { get set }
}

extension NewHeaderAnimatedSceneProtocol {
   var minHeaderHeight: CGFloat { 88 }
   var maxHeaderHeight: CGFloat { 298.aspected }

   var animationDuration: TimeInterval { 0.36 }

   var isHeaderPresented: Bool {
      headerHeightConstraint?.constant ?? 0 > minHeaderHeight
   }

   var isNavBarEnabled: Bool { true }

   func presentHeader(_ animate: @escaping () -> Void = {}) {
      if headerHeightConstraint == nil {
         headerHeightConstraint = headerViewModel.view.addAnchors.constHeight(maxHeaderHeight).constraint()
      }
      if !isNavBarEnabled { mainVM.navBar.hidden(true) }

      UIView.animate(withDuration: animationDuration) {
         animate()
         if self.isNavBarEnabled { self.mainVM.navBar.hidden(true) }
         self.headerHeightConstraint?.constant = self.maxHeaderHeight
         self.mainVM.view.layoutIfNeeded()
      } completion: { _ in
      }
   }

   func hideHeader(_ animate: @escaping () -> Void = {}) {
      if headerHeightConstraint == nil {
         headerHeightConstraint = headerViewModel.view.addAnchors.constHeight(minHeaderHeight).constraint()
      }
      if isNavBarEnabled { 
         mainVM.navBar.hidden(false)
      } else {
         mainVM.navBar.hidden(true)
      }
      UIView.animate(withDuration: animationDuration) {
         animate()
         if self.isNavBarEnabled { 
            self.mainVM.navBar.hidden(false)
         }
         self.headerHeightConstraint?.constant = self.minHeaderHeight
         self.mainVM.view.layoutIfNeeded()
      } completion: { _ in
      }
   }

   func setNavBarStyleForImage(_ image: UIImage, backColor: UIColor? = nil) {
      headerBrightness = image.brightnessStyleOfTopLeftImageContent(backColor: backColor)
   }

   func updateNavBarTintForHeaderImage() {
      switch headerBrightness {
      case .dark:
         setNavBarTintLight()
      case .light:
         setNavBarTintDark()
      }
   }

   func setNavBarTintLight() {
      vcModel?
         .barStyle(.black)
         .titleColor(Design.color.iconInvert)
         .navBarTintColor(Design.color.iconInvert)
         .statusBarStyle(.lightContent)
         .titleAlpha(1)
   }

   func setNavBarTintDark() {
      vcModel?
         .barStyle(.default)
         .titleColor(Design.color.textBrand)
         .navBarTintColor(Design.color.textBrand)
         .statusBarStyle(.darkContent)
         .titleAlpha(1)
   }

   func setNavBarInvisible() {
      vcModel?
         .titleColor(Design.color.transparent)
         .navBarTintColor(Design.color.transparent)
         .titleAlpha(0)
   }
}
