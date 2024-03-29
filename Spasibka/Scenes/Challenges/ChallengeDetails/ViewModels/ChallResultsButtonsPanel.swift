//
//  CopyAndSendButtonsPanel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.02.2024.
//

import StackNinja

final class ChallResultsButtonsPanel<Design: DSP>: StackModel, Designable {

   var resultsButton: ButtonModel { buttons.models.main }
   var sendButton: ButtonSelfModable { buttons.models.right }

   // Private

   private lazy var buttons = Stack<ButtonModel>.R<ButtonSelfModable>.Ninja()
      .setAll { copyButton, sendButton in
         sendButton
            .set(Design.state.button.default)
            .font(Design.font.descriptionMedium12)
            .title(Design.text.sendResult)
            .hidden(true)
            .removeAllConstraints()
            .height(44)
         copyButton
            .set(Design.state.button.default)
            .backColor(Design.color.backgroundInfoSecondary)
            .image(Design.icon.clipboardText, color: Design.color.iconContrast)
            .removeAllConstraints()
            .width(44)
      }
      .spacing(8)

   override func start() {
      super.start()
      resultsButton.view.startTapGestureRecognize()

      arrangedModels([
         Grid.x16.spacer,
         buttons
      ])
      alignment(.leading)
   }
}

