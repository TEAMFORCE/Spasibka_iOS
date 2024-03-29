//
//  ChainStepsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 31.01.2024.
//

import StackNinja

struct ChainStepsParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyFooterStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = ChallengeGroup
      typealias Output = Void
   }
}

final class ChainStepsScene<Asset: AssetProtocol>: BaseParamsScene<ChainStepsParams<Asset>> {
   private lazy var descriptionBlock = M<LabelModel>.R<LabelModel>.Ninja()
      .setAll {
         $0
            .set(Design.state.label.descriptionRegular14)
            .textColor(Design.color.textSecondary)
            .text(Design.text.challengeChains)
         $1
            .set(Design.state.label.descriptionMedium14)
            .textColor(Design.color.text)
      }
      .spacing(5)
      .padHorizontal(16)
      .padBottom(16)

   private lazy var chainStepsModel = ChainChallengesModel<Asset>()

   override func start() {
      super.start()

      mainVM.navBar.titleLabel.text(Design.text.steps)
      mainVM.navBar.secondaryButtonHidden(true)
      mainVM
         .bodyStack
         .arrangedModels(
            descriptionBlock.lefted(),
            chainStepsModel.viewModel
         )

      on(\.input, self) {
         $0.chainStepsModel.startWithPayload($1)
         $0.descriptionBlock.models.right.text($1.name.unwrap)
      }

   }
}
