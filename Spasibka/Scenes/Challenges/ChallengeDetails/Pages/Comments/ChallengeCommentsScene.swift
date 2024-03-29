//
//  ChallengeCommentsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.02.2024.
//

import StackNinja


struct ChallengeCommentsParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyFooterStack<Asset, PresentBottomScheet>
   }

   struct InOut: InOutParams {
      typealias Input = Challenge
      typealias Output = Void
   }
}

final class ChallengeCommentsScene<Asset: AssetProtocol>: BaseParamsScene<ChallengeCommentsParams<Asset>> {
   private lazy var descriptionBlock = M<LabelModel>.R<LabelModel>.Ninja()
      .setAll {
         $0
            .set(Design.state.label.descriptionRegular14)
            .textColor(Design.color.textSecondary)
            .text(Design.text.toChallenge)
         $1
            .set(Design.state.label.descriptionMedium14)
            .textColor(Design.color.text)
      }
      .spacing(5)
      .padHorizontal(16)
      .padBottom(16)

   private lazy var challengeCommentsModel = ChallengeCommentsModel<Asset>()

   override func start() {
      super.start()

      mainVM.navBar.titleLabel.text(Design.text.comments)
      mainVM.navBar.secondaryButtonHidden(true)
      mainVM
         .bodyStack
         .arrangedModels(
            descriptionBlock.lefted(),
            challengeCommentsModel.viewModel.padHorizontal(16)
         )

      on(\.input, self) {
         $0.challengeCommentsModel.startWithPayload($1)
         $0.descriptionBlock.models.right.text($1.name.unwrap)
      }

   }
}
