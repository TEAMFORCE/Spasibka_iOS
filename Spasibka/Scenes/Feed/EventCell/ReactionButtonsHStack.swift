//
//  ReactionButtonsHStack.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.07.2023.
//

import StackNinja

final class ReactionButtonsHStack<Design: DSP>: HStackModel {

   var didTapMessageButtonWork: VoidWork {
      messageButton.view.on(\.didTap)
   }

   var didTapLikeButtonWork: VoidWork {
      likeButton.view.on(\.didTap)
   }

   let messageButton = ReactionButton<Design>()
      .setAll { image, _ in
         image.image(Design.icon.chatCircle)
      }

   let likeButton = ReactionButton<Design>()
      .setAll { image, _ in
         image.image(Design.icon.heart)
      }

   override func start() {
      super.start()

      alignment(.leading)
      distribution(.fill)
      spacing(4)
      padTop(8)

      messageButton.view.startTapGestureRecognize(cancelTouch: true)
      likeButton.view.startTapGestureRecognize(cancelTouch: true)

      arrangedModels(Spacer(), messageButton, likeButton)
   }
}
