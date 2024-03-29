//
//  CGSize+Ext.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 17.12.2022.
//

import Foundation

extension CGSize {
   static func square(_ size: CGFloat) -> CGSize {
      .init(width: size, height: size)
   }
}
