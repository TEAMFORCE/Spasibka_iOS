//
//  Fonts.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.07.2022.
//

import StackNinja
import UIKit

protocol FontProtocol: TypographyElements where DesignElement == UIFont {}

extension FontBuilder {
   func font(ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
      .systemFont(ofSize: ofSize, weight: weight)
   }
}

extension FontBuilder {
   func descriptionFont(ofSize: CGFloat, weight: UIFont.Weight) -> UIFont {
      switch weight {
      case .medium:
         return UIFont(name: "Montserrat-Medium", size: ofSize)!
      case .regular:
         return UIFont(name: "Montserrat-Regular", size: ofSize)!
      case .bold:
         return UIFont(name: "Montserrat-Bold", size: ofSize)!
      default:
         return UIFont(name: "Montserrat-Regular", size: ofSize)!
      }
   }
}

struct FontBuilder: FontProtocol {
   var medium8: UIFont { font(ofSize: 8, weight: .medium) }

   var regular9: UIFont { font(ofSize: 9, weight: .regular) }

   var medium10: UIFont { font(ofSize: 10, weight: .medium) }

   var regular14: UIFont { font(ofSize: 14, weight: .regular) }
   var semibold14: UIFont { font(ofSize: 14, weight: .semibold) }
   var medium14: UIFont { font(ofSize: 14, weight: .medium) }

   var regular14brand: UIFont { font(ofSize: 14, weight: .regular) }

   var regular14error: UIFont { font(ofSize: 14, weight: .regular) }

   var medium16: UIFont { font(ofSize: 16, weight: .medium) }

   var regular12Secondary: UIFont { font(ofSize: 12, weight: .regular) }

   var regular12Error: UIFont { font(ofSize: 12, weight: .regular) }

   var semibold54: UIFont { font(ofSize: 54, weight: .semibold) }
   var bold32: UIFont { font(ofSize: 32, weight: .bold) }
   var bold28: UIFont { font(ofSize: 28, weight: .bold) }
   var regular20: UIFont { font(ofSize: 20, weight: .regular) }
   var semibold20: UIFont { font(ofSize: 20, weight: .semibold) }

   var medium20: UIFont { font(ofSize: 20, weight: .medium) }
   var medium20invert: UIFont { font(ofSize: 20, weight: .medium) }

   var regular24: UIFont { font(ofSize: 24, weight: .regular) }
   var bold24: UIFont { font(ofSize: 24, weight: .bold) }
   var medium24: UIFont { font(ofSize: 24, weight: .medium) }

   var bold14: UIFont { font(ofSize: 14, weight: .bold) }
   var semibold16: UIFont { font(ofSize: 16, weight: .semibold) }

   var semibold14secondary: UIFont { font(ofSize: 14, weight: .regular) }

   var regular16: UIFont { font(ofSize: 16, weight: .regular) }
   var regular16Secondary: UIFont { font(ofSize: 16, weight: .regular) }

   var regular12: UIFont { font(ofSize: 12, weight: .regular) }
   var medium12: UIFont { font(ofSize: 12, weight: .medium) }
   var regular10: UIFont { font(ofSize: 10, weight: .regular) }
   var regular40: UIFont { font(ofSize: 40, weight: .regular) }
   var regular48: UIFont { font(ofSize: 48, weight: .regular) }

   var bold8: UIFont { font(ofSize: 8, weight: .bold) }

   var descriptionRegular8: UIFont { descriptionFont(ofSize: 8, weight: .regular) }
   var descriptionRegular10: UIFont { descriptionFont(ofSize: 10, weight: .regular) }
   var descriptionRegular12: UIFont { descriptionFont(ofSize: 12, weight: .regular) }
   var descriptionRegular14: UIFont { descriptionFont(ofSize: 14, weight: .regular) }
   var descriptionRegular16: UIFont { descriptionFont(ofSize: 16, weight: .regular) }
   var descriptionRegular20: UIFont { descriptionFont(ofSize: 20, weight: .regular) }
   var descriptionRegualer64: UIFont { descriptionFont(ofSize: 64, weight: .regular) }

   var descriptionMedium8: UIFont { descriptionFont(ofSize: 8, weight: .medium) }
   var descriptionMedium10: UIFont { descriptionFont(ofSize: 10, weight: .medium) }
   var descriptionMedium12: UIFont { descriptionFont(ofSize: 12, weight: .medium) }
   var descriptionMedium14: UIFont { descriptionFont(ofSize: 14, weight: .medium) }
   var descriptionMedium16: UIFont { descriptionFont(ofSize: 16, weight: .medium) }
   var descriptionMedium18: UIFont { descriptionFont(ofSize: 18, weight: .medium) }
   var descriptionMedium20: UIFont { descriptionFont(ofSize: 20, weight: .medium) }
   var descriptionMedium36: UIFont { descriptionFont(ofSize: 36, weight: .medium) }
   var descriptionMedium64: UIFont { descriptionFont(ofSize: 64, weight: .medium) }
   
   var descriptionBold36: UIFont { descriptionFont(ofSize: 36, weight: .bold) }
   var descriptionBold48: UIFont { descriptionFont(ofSize: 48, weight: .bold) }
   var descriptionBold64: UIFont { descriptionFont(ofSize: 64, weight: .bold) }
   
   var labelRegular14: UIFont { UIFont(name: "Inter-Regular", size: 14)! }
   var labelRegular16: UIFont { UIFont(name: "Inter-Regular", size: 16)! }
   var labelRegularContrastColor14: UIFont { UIFont(name: "Inter-Regular", size: 14)! }
   var labelRegular10: UIFont { UIFont(name: "Inter-Regular", size: 10)! }
   var descriptionSecondary12: UIFont { UIFont(name: "Inter-Regular", size: 12)! }
}
