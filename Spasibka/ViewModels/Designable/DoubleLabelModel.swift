//
//  DoubleLabelModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.07.2022.
//

import StackNinja
import UIKit

final class DoubleLabelModel<Design: DesignProtocol>: BaseViewModel<StackViewExtended>,
   Designable
{
   lazy var labelLeft = Design.label.bold14
   lazy var labelRight = Design.label.bold14

   override func start() {
      axis(.horizontal)
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadius)
      distribution(.fill)
      alignment(.fill)
      padding(.init(top: 12, left: 16, bottom: 12, right: 16))
      arrangedModels([
         labelLeft,
         Spacer(),
         labelRight,
      ])
   }
}

extension DoubleLabelModel: Stateable2 {
   typealias State = StackState
   typealias State2 = ViewState
}
