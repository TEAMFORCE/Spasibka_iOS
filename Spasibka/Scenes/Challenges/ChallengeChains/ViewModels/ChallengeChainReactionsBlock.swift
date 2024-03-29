//
//  ChallengeChainReactionsBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.02.2024.
//

import StackNinja

final class ChallengeChainReactionsBlock<Design: DSP>: VStackModel {
   private(set) lazy var shareButton = ButtonModel()
      .image(Design.icon.arrowLineUp, color: Design.color.constantWhite)
   private(set) lazy var likesBlock = ReactionBlockModel<Design>.likes
   private(set) lazy var commentsBlock = ReactionBlockModel<Design>.comments
   private(set) lazy var editChallengeButton = ButtonModel()
      .image(Design.icon.pencilSimple, color: Design.color.constantWhite)
      .size(.square(30))
      .hidden(true)

   override func start() {
      super.start()

      spacing(20)
      arrangedModels(shareButton, likesBlock, commentsBlock, editChallengeButton)
   }
}

final class BenefitReactionsBlock<Design: DSP>: VStackModel {
   private(set) lazy var basketButton = ButtonModel()
      .image(Design.icon.basket.resized(to: .square(24)), color: Design.color.constantWhite)
   
   private(set) lazy var likesBlock = ReactionBlockModel<Design>.likes
      .hidden(true)
   private(set) lazy var commentsBlock = ReactionBlockModel<Design>.comments
      .hidden(true)

   override func start() {
      super.start()

      spacing(20)
      arrangedModels(basketButton, likesBlock, commentsBlock)
   }
}
