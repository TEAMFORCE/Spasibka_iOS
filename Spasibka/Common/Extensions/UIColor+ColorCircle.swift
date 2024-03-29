//
//  UIColor+ColorCircle.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.12.2022.
//

import UIKit

extension UIColor {
   var hue: CGFloat {
      var hue: CGFloat = 0.0
      var saturation: CGFloat = 0.0
      var brightness: CGFloat = 0.0
      var alpha: CGFloat = 0.0

      getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
      return hue
   }

   var saturation: CGFloat {
      var hue: CGFloat = 0.0
      var saturation: CGFloat = 0.0
      var brightness: CGFloat = 0.0
      var alpha: CGFloat = 0.0

      getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
      return saturation
   }

   var brightness: CGFloat {
      var hue: CGFloat = 0.0
      var saturation: CGFloat = 0.0
      var brightness: CGFloat = 0.0
      var alpha: CGFloat = 0.0

      getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
      return brightness
   }

   func colorsCircle(_ count: Int, saturate: CGFloat, bright: CGFloat) -> [UIColor] {
      let step = 1.0 / CGFloat(count)
      var hue = hue
      let colors = (0..<count).map { _ in
         let color = UIColor(hue: hue, saturation: saturate, brightness: bright, alpha: 1)
         hue += step
         return color
      }

      return colors
   }

   func colorsCircle(_ count: Int) -> [UIColor] {
      let step = 1.0 / CGFloat(count)
      var hue = hue
      let sat = saturation
      let bri = brightness
      let colors = (0..<count).map { _ in
         let color = UIColor(hue: hue, saturation: sat, brightness: bri, alpha: 1)
         hue += step
         return color
      }

      return colors
   }
}

