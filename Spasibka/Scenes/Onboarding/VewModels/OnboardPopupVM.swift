//
//  OnboardPopupVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 31.05.2023.
//

import StackNinja

final class OnboardPopupVM<Design: DSP>: VStackModel {
   private let titleLabel = Design.label.medium20
   private let subtitleLabel = Design.label.regular16Secondary

   let inputField = TextFieldModel()
      .set(Design.state.textField.default)
      .clearButtonMode(.whileEditing)

   let continueButton = Design.button.default
      .title(Design.text.continue)

   let cancelButton = Design.button.transparent
      .title(Design.text.cancel)

   override func start() {
      backColor(Design.color.background)
      padding(.init(top: 28, left: 16, bottom: 16, right: 16))
      spacing(16)
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadiusBig)
      disableBottomRadius(20)
      arrangedModels(
         titleLabel.centeredX(),
         subtitleLabel,
         inputField,
         continueButton,
         cancelButton
      )
   }
}

enum OnboardPopupState {
   case initial(
      title: String,
      subtitle: String,
      inputPlaceholder: String
   )

   case continueButtonEnabled(Bool)
   case textFieldText(String)
}

extension OnboardPopupVM: StateMachine {
   func setState(_ state: OnboardPopupState) {
      switch state {
      case let .initial(title, subtitle, placeholder):
         titleLabel.text(title)
         subtitleLabel.text(subtitle)
         inputField.placeholder(placeholder)
      case let .continueButtonEnabled(enabled):
         if enabled {
            continueButton.set(Design.state.button.default)
         } else {
            continueButton.set(Design.state.button.inactive)
         }
      case let .textFieldText(text):
         inputField.text(text)
      }
   }
}
