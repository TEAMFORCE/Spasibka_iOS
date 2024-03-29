//
//  DoubleLabelPairModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.07.2022.
//

import StackNinja
import UIKit

enum DoubleLabelPairState {
   case leftPair(text1: String, text2: String)
   case rightPair(text1: String, text2: String)
}

final class DoubleLabelPairModel<Design: DesignProtocol>: BaseViewModel<StackViewExtended>,
   Designable
{
   let doubleLabelLeft = DoubleLabelModel<Design>()
   let doubleLabelRight = DoubleLabelModel<Design>()

   typealias State = StackState

   override func start() {
      axis(.horizontal)
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadius)
      distribution(.fillProportionally)
      alignment(.fill)
      arrangedModels([
         doubleLabelLeft,
         doubleLabelRight,
      ])
   }
}

extension DoubleLabelPairModel: Stateable2 {
   func applyState(_ state: DoubleLabelPairState) {
      switch state {
      case let .leftPair(text1: text1, text2: text2):
         doubleLabelLeft.labelLeft.set(.text(text1))
         doubleLabelLeft.labelRight.set(.text(text2))
      case let .rightPair(text1: text1, text2: text2):
         doubleLabelRight.labelLeft.set(.text(text1))
         doubleLabelRight.labelRight.set(.text(text2))
      }
   }
}
