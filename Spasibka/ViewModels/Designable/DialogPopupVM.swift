//
//  TitleButtonButtonPopupVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.06.2023.
//

import StackNinja
import UIKit

final class DialogPopupVM<Design: DSP>: VStackModel {
   var didTapButtonWork: VoidWork { continueButton.on(\.didTap) }
   var didTapCancelButtonWork: VoidWork { cancelButton.on(\.didTap) }

   private let imageModel = ImageViewModel()

   private let titleLabel = Design.label.medium20
      .alignment(.center)
      .numberOfLines(0)
   private let subtitleLabel = Design.label.regular16Secondary
      .numberOfLines(0)

   private let continueButton = Design.button.default
      .title(Design.text.continue)

   private let cancelButton = Design.button.transparent
      .title(Design.text.cancel)

   override func start() {
      backColor(Design.color.background)
      padding(.init(top: 28, left: 16, bottom: 16, right: 16))
      spacing(16)
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadiusBig)
      disableBottomRadius(20)
      arrangedModels(
         imageModel.hidden(true),
         titleLabel.centeredX(),
         subtitleLabel.hidden(true),
         continueButton,
         cancelButton
      )
   }
}

extension DialogPopupVM: StateMachine {
   struct ModelState {
      let image: UIImage?
      let title: String?
      let subtitle: String?
      let buttonText: String?
      let buttonSecondaryText: String?

      init(
         image: UIImage? = nil,
         title: String? = nil,
         subtitle: String? = nil,
         buttonText: String? = nil,
         buttonSecondaryText: String? = nil
      ) {
         self.image = image
         self.title = title
         self.subtitle = subtitle
         self.buttonText = buttonText
         self.buttonSecondaryText = buttonSecondaryText
      }
   }

   func setState(_ state: ModelState) {
      if let image = state.image {
         imageModel.hidden(false)
         imageModel.image(image)
      } else {
         imageModel.hidden(true)
      }
      if let title = state.title {
         titleLabel.text(title)
         titleLabel.hidden(false)
      } else {
         titleLabel.hidden(true)
      }
      if let subtitle = state.subtitle {
         subtitleLabel.hidden(false)
         subtitleLabel.text(subtitle)
      } else {
         subtitleLabel.hidden(true)
      }
      if let buttonText = state.buttonText {
         continueButton.hidden(false)
         continueButton.title(buttonText)
      } else {
         continueButton.hidden(true)
      }
      if let buttonSecondaryText = state.buttonSecondaryText {
         cancelButton.hidden(false)
         cancelButton.title(buttonSecondaryText)
      } else {
         cancelButton.hidden(true)
      }
   }
}
