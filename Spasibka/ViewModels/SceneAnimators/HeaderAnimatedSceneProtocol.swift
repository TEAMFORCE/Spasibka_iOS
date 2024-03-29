//
//  HeaderAnimatedSceneProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.01.2023.
//

import StackNinja
import UIKit

// MARK: - Header animation

protocol HeaderAnimatedSceneProtocol: SceneModel, Assetable
   where Asset: AssetProtocol, MainViewModel: HeaderBodyFooterStackModel
{
   associatedtype HeaderViewModel: ViewModelProtocol
   var headerTitle: String { get }
   var headerViewModel: HeaderViewModel { get }
   var headerBrightness: ColorBrightnessStyle { get set }
   
}

extension HeaderAnimatedSceneProtocol {
   var isHeaderPresented: Bool {
      mainVM.headerStack.view.isHidden == false
   }

   func presentHeader() {
      if vcModel?.isModal == false {
         vcModel?.navigationController?.navigationBar.backgroundColor = Design.color.transparent
      }

      UIView.animate(withDuration: 0.36) {
         self.mainVM.headerStack
            .hidden(false)
            .alpha(1)
         if self.vcModel?.isModal == false {
            self.vcModel?.navBarTranslucent(true)
            self.updateNavBarTintForHeaderImage()
            self.vcModel?.title("")
         }
      } completion: { _ in
         if self.vcModel?.isModal == false {
            self.vcModel?.navBarTranslucent(true)
            self.updateNavBarTintForHeaderImage()
            self.vcModel?.title("")
         }
      }
   }

   func hideHeader() {
      UIView.animate(withDuration: 0.36) {
         self.mainVM.headerStack
            .alpha(0)
            .hidden(true)

         if self.vcModel?.isModal == false {
            self.vcModel?.navBarTranslucent(false)
         }
      } completion: { _ in
         if self.vcModel?.isModal == false {
            self.vcModel?
               .navBarBackColor(Design.color.backgroundBrand)
            self.vcModel?.title(self.headerTitle)
            if self.vcModel?.isModal == false {
               self.vcModel?.navBarTranslucent(false)
            }
            self.setNavBarTintLight()
         }
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
}
