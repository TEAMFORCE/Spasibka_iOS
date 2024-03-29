//
//  GhostBackLogo.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 25.08.2023.
//

import StackNinja
import UIKit

final class ChostBackLogo<Design: DSP>: StackModel {

   private let size: CGFloat

   init(size: CGFloat) {
      self.size = size
      super.init()
   }

   required init() {
      fatalError("init() has not been implemented")
   }

   private(set) lazy var logo = ImageViewModel()
      .image(Design.icon.smallLogo, color: Design.color.iconInvert)
      .rotate(-49)
      .wrappedX()
      .backColor(Design.color.backgroundBrand)
      .size(.square(size))
      .padding(.outline(12))
      .cornerRadius(size/2)

   override func start() {
      super.start()

      arrangedModels(
         Spacer(),
         Wrapped3X(
            Spacer(),
            logo,
            Spacer()
         )
         .distribution(.equalSpacing),
         Spacer()
      )
      distribution(.equalSpacing)
   }
}

final class BalanceBackLogo<Design: DSP>: StackModel {

   private let size: CGFloat

   init(size: CGFloat) {
      self.size = size
      super.init()
   }

   required init() {
      fatalError("init() has not been implemented")
   }

   private(set) lazy var logo = ImageViewModel()
      .image(Design.icon.balanceCellBackground)
      .imageTintColor(UIColor("FFFFFF", alpha: 1))
      .wrappedX()
      .size(.square(size))

   override func start() {
      super.start()
      
      arrangedModels(
         Spacer(),
         Wrapped3X(
            Spacer(),
            logo,
            Spacer()
         )
         .distribution(.equalSpacing),
         Spacer()
      )
      distribution(.equalSpacing)
   }
}
