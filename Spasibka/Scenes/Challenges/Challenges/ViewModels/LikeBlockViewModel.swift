//
//  LikeBlockViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.01.2024.
//

import StackNinja

extension ReactionBlockModel {
   static var likes: ReactionBlockModel {
      .init {
         $0.icon
            .image(Design.icon.heart, color: Design.color.constantWhite)
      }
   }

   static var comments: ReactionBlockModel {
      .init {
         $0.icon
            .image(Design.icon.chatCircle, color: Design.color.constantWhite)
      }
   }
}

extension ReactionBlockModel {
   func setLiked(_ liked: Bool) {
      if liked {
         icon
            .image(Design.icon.redHeart)
            .imageTintColor(Design.color.iconError)
      } else {
         icon
            .image(Design.icon.heart)
            .imageTintColor(Design.color.constantWhite)
      }
   }
}

final class ReactionBlockModel<Design: DSP>: M<ImageViewModel>.D<LabelModel>.Ninja {
   let button = ButtonModel()

   var icon: ImageViewModel {
      models.main
   }

   var label: LabelModel {
      models.down
   }

   required init() {
      super.init()

      setAll {
         $0
            .size(.square(24))
         $1
            .alignment(.center)
            .set(Design.state.label.descriptionMedium10)
            .textColor(Design.color.textInvert)
            .text("0")
      }
      .backViewModel(button)
      .spacing(3)
      .backColor(Design.color.constantBlack.withAlphaComponent(0.5))
      .padding(.outline(5))
      .cornerCurve(.continuous)
      .cornerRadius(6)

      //startTapGestureRecognize(cancelTouch: true)
   }
}
