//
//  CommonErrorBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.09.2022.
//

import Foundation
import StackNinja

final class CommonErrorSpacedBlock<Design: DSP>: StackModel {
   let title =  Design.label.medium16
      .text(Design.text.loadPageError)
   let subtitle =  Design.label.regular14
      .text(Design.text.connectionError)
   let errorImage = ImageViewModel()
      .image(Design.icon.errorIllustrate)
      .size(.square(220))
   override func start() {
      alignment(.center)
      arrangedModels([
         errorImage,
         Grid.x20.spacer,
         title,
         Grid.x20.spacer,
         subtitle,
         Grid.xxx.spacer
      ])
   }
}
