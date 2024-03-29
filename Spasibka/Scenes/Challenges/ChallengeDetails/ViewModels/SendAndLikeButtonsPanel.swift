//
//  SendChallengePanel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.11.2022.
//

import StackNinja

final class SendAndLikeButtonsPanel<Design: DSP>: StackModel, Designable {
   var sendButton: ButtonSelfModable { buttons.models.main }
   var likeButton: ReactionButton<Design> { buttons.models.right }

   // Private

   private lazy var buttons = Stack<ButtonSelfModable>.R<ReactionButton<Design>>.Ninja()
      .setAll { sendButton, likeButton in
         sendButton
            .set(Design.state.button.default)
            .font(Design.font.medium16)
            .title(Design.text.sendResult)
            .hidden(true)
         likeButton
            .setAll {
               $0.image(Design.icon.like)
               $1
                  .font(Design.font.regular12)
                  .text("0")
            }
            .removeAllConstraints()
            .width(68)
      }
      .spacing(8)

   override func start() {
      super.start()
      likeButton.view.startTapGestureRecognize()

      arrangedModels([
         Grid.x16.spacer,
         buttons.height(Design.params.buttonHeight)
      ])
      alignment(.trailing)
   }
}
