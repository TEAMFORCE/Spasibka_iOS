//
//  OnboardPageVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import StackNinja
import UIKit

final class OnboardPageVM<Design: DSP>: VStackModel {
   private lazy var imageModel = ImageViewModel()
      .maxWidth(256.aspectedByHeight)
      .maxHeight(256.aspectedByHeight)
      .contentMode(.scaleAspectFit)

   private(set) var buttonModel = ButtonModel()
      .set(Design.state.button.default)

   override func start() {
      super.start()

      padding(.outline(48))
      arrangedModels(
         imageModel,
         Spacer(64.aspectedByHeight),
         buttonModel
      )
      backViewModel(
         ViewModel()
            .userInterractionEnabled(false)
            .backColor(Design.color.background)
            .cornerCurve(.continuous)
            .cornerRadius(Design.params.cornerRadiusBig)
            .shadow(.init(
               radius: 12,
               offset: .init(x: 0, y: 6),
               color: Design.color.iconContrast,
               opacity: 0.19
            )),
         inset: .outline(16)
      )
   }
}

enum OnboardPageState {
   case initialValues(image: UIImage, buttonText: String)
}

extension OnboardPageVM: StateMachine {
   func setState(_ state: OnboardPageState) {
      switch state {
      case let .initialValues(image, buttonText):
         imageModel.image(image)
         buttonModel.title(buttonText)
      }
   }
}
