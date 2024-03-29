//
//  ChallengeUsersScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.02.2024.
//

import StackNinja

struct ChallengeUsersSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentBottomScheet>
   }

   struct InOut: InOutParams {
      typealias Input = Challenge
      typealias Output = Void
   }
}

final class ChallengeUsersScene<Asset: AssetProtocol>: BaseParamsScene<ChallengeUsersSceneParams<Asset>> {
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

   private lazy var challengeUsersModel = ChallengeUsersModel<Asset>()

   override func start() {
      super.start()

      mainVM.navBar.titleLabel.text(Design.text.participants)
      mainVM.navBar.secondaryButtonHidden(true)
      mainVM
         .bodyStack
         .arrangedModels(
            descriptionBlock.lefted(),
            challengeUsersModel.viewModel
         )

      on(\.input, self) {
         $0.challengeUsersModel.startWithPayload($1)
         $0.descriptionBlock.models.right.text($1.name.unwrap)
      }

   }
}
