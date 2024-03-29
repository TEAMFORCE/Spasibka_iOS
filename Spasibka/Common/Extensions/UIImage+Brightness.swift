//
//  UIImage+Brightness.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.11.2022.
//

import UIKit

enum ColorBrightnessStyle {
   static let brightnessTreshold: CGFloat = 0.65

   case dark
   case light

   var isLight: Bool {
      switch self {
      case .light:
         return true
      case .dark:
         return false
      }
   }
}

extension UIImage {
   private static let resizeImageWidth: CGFloat = 24.0

   func brightnessStyleOfTopLeftImageContent(backColor: UIColor? = nil) -> ColorBrightnessStyle {
      let backColorBrightness: CGFloat = backColor?.lightness ?? 0.0

      let coef = size.width / size.height
      let resizeHeight = round(Self.resizeImageWidth / coef)
      let checkImage = self
         .cropped(rect: CGRect(x: 0, y: 0, width: size.width / 8, height: size.height / 2))
         .resized(to: CGSize(width: Self.resizeImageWidth, height: resizeHeight))
      let brightness = checkImage.brightness + backColorBrightness
      let isImageLight = brightness > ColorBrightnessStyle.brightnessTreshold

      return isImageLight ? .light : .dark
   }
}

extension UIColor {
   var lightness: CGFloat {
      var white: CGFloat = 0
      getWhite(&white, alpha: nil)
      return white
   }

   func brightnessStyle(brightnessTreshold: CGFloat? = nil) -> ColorBrightnessStyle {
      let thresh = brightnessTreshold ?? ColorBrightnessStyle.brightnessTreshold
      return lightness > thresh ? .light : .dark
   }
}

