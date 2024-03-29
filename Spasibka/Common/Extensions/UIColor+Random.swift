//
//  UIColor+Random.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.08.2022.
//

import UIKit

extension UIColor {
   static var random: UIColor {
      .init(hue: .random(in: 0 ... 1), saturation: 0.33, brightness: 1, alpha: 0.4)
   }
}
