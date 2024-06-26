//
//  UIView+Constraints.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.11.2022.
//

import UIKit

extension UIView {
   func removeAllConstraints() {
      var _superview = superview

      while let superview = _superview {
         for constraint in superview.constraints {
            if let first = constraint.firstItem as? UIView, first == self {
               superview.removeConstraint(constraint)
            }

            if let second = constraint.secondItem as? UIView, second == self {
               superview.removeConstraint(constraint)
            }
         }

         _superview = superview.superview
      }

      removeConstraints(constraints)
      translatesAutoresizingMaskIntoConstraints = true
   }
}
