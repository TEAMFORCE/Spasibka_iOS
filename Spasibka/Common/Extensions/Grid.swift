//
//  Spacer.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.06.2022.
//

import Anchorage
import StackNinja
import UIKit

enum Grid: CGFloat {
   case x1 = 1
   case x2 = 2
   case x4 = 4
   case x6 = 6
   case x8 = 8
   case x10 = 10
   case x12 = 12
   case x14 = 14
   case x16 = 16
   case x20 = 20
   case x24 = 24
   case x26 = 26
   case x30 = 30
   case x32 = 32
   case x36 = 36
   case x40 = 40
   case x48 = 48

   case x50 = 50

   case x60 = 60
   case x64 = 64

   case x70 = 70
   case x80 = 80
   case x90 = 90
   case x100 = 100
   case x128 = 128
   case x256 = 256

   // case infinity
   case xxx = 0
}

enum GridAsp: CGFloat {
   case x1 = 1
   case x2 = 2
   case x4 = 4
   case x6 = 6
   case x8 = 8
   case x10 = 10
   case x12 = 12
   case x14 = 14
   case x16 = 16
   case x20 = 20
   case x24 = 24
   case x30 = 30
   case x32 = 32
   case x36 = 36
   case x40 = 40
   case x48 = 48

   case x50 = 50

   case x60 = 60
   case x64 = 64

   case x70 = 70
   case x80 = 80
   case x90 = 90
   case x100 = 100
   case x128 = 128
   case x256 = 256

   // case infinity
   case xxx = 0
}

extension Grid {
   var spacer: Spacer {
      Spacer(value)
   }

   var value: CGFloat {
      CGFloat(rawValue)
   }
}

extension GridAsp {
   var spacer: Spacer {
      Spacer(value * Config.sizeAspectCoeficient)
   }

   var value: CGFloat {
      CGFloat(rawValue)
   }
}
