//
//  CloudVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 09.08.2023.
//

import UIKit
import StackNinja

final class CloudVM: StackModel {
   override func start() {
      spacing(4)
      alignment(.leading)
   }
}

extension CloudVM: StateMachine {
   func setState(_ state: [UIViewModel]) {
      arrangedModels([])
      var currStack = StackModel()
         .axis(.horizontal)
         .spacing(4)
      var tagButts: [UIViewModel] = []
      let width = view.frame.width / 1.1
      var currWidth: CGFloat = 0
      let spacing: CGFloat = 4

      view.layoutIfNeeded()
      state.enumerated().forEach { ind, tag in
         currStack.addArrangedModels([tag])

         let fittingSize = tag.uiView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
         let butWidth = fittingSize.width

         currWidth += butWidth + spacing

         let isNotFit = currWidth > width
         if isNotFit || (ind == state.count - 1) {
            tagButts.append(currStack)
            currStack = StackModel()
               .axis(.horizontal)
               .spacing(4)
            //   .arrangedModels([tag])
            tagButts.append(currStack)
            currWidth = 0
         }
      }

      arrangedModels(tagButts)
   }
}
