//
//  TitleTextFieldButtonVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 31.05.2023.
//

import StackNinja
import UIKit

final class TitleTextFieldButtonVM<Design: DSP>: VStackModel {

   private (set) lazy var didTap = wrapper.view.on(\.didTap)

   // Private

   let titleLabel = Design.label.regular16
      .textColor(Design.color.textSecondary)

   let textField = TextFieldModel()
      .set(Design.state.textField.invisible)

   let textFieldButton = ButtonModel()
      .set(Design.state.button.transparent)
      .size(.square(32))
      .hidden(true)

   private (set) lazy var wrapper = Wrapped2X(textField, textFieldButton)
      .height(Design.params.buttonHeight)
      .backColor(Design.color.textFieldBack)
      .height(Design.params.buttonHeight)
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadius)
      .borderWidth(Design.params.borderWidth)
      .borderColor(Design.color.boundary)
      .padding(.horizontalOffset(12))

   override func start() {
      super.start()

      spacing(10)
      arrangedModels(
         titleLabel,
         wrapper
      )

      wrapper.view.startTapGestureRecognize()
   }
}

enum TitleTextFieldButtonState {
   case title(String)
   case placeHolder(String)
   case textFieldText(String)
   case buttonImage(UIImage)

   case enabled(Bool)
   case textFieldUserInterractionEnabled(Bool)
}

extension TitleTextFieldButtonVM: StateMachine {
   func setState(_ state: TitleTextFieldButtonState) {
      switch state {
      case let .enabled(isEnabled):
         if isEnabled {
            wrapper
               .backColor(Design.color.background)
               .userInterractionEnabled(true)
            textField
               .alpha(1)
            textFieldButton
               .alpha(1)
         } else {
            wrapper
               .backColor(Design.color.backgroundSecondary.withAlphaComponent(0.5))
               .userInterractionEnabled(false)
            textField
               .alpha(0.35)
            textFieldButton
               .alpha(0.35)
         }
      case .title(let text):
         titleLabel.text(text)
      case .textFieldText(let text):
         textField.text(text)
         DispatchQueue.main.async { [weak self] in
            self?.textField.send(\.didEditingChanged, text)
         }
      case .buttonImage(let image):
         textFieldButton
            .image(image)
            .hidden(false)
      case .textFieldUserInterractionEnabled(let enabled):
         textField.userInterractionEnabled(enabled)
      case .placeHolder(let text):
         textField.placeholder(text)
      }
   }
}
