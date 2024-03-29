//
//  ChainParticipantsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.02.2024.
//

import StackNinja

struct ChainParticipantsParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyFooterStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = ChallengeGroup
      typealias Output = Void
   }
}

final class ChainParticipantsScene<Asset: AssetProtocol>: BaseParamsScene<ChainParticipantsParams<Asset>> {
   private lazy var descriptionBlock = M<LabelModel>.R<LabelModel>.Ninja()
      .setAll {
         $0
            .set(Design.state.label.descriptionRegular14)
            .textColor(Design.color.textSecondary)
            .text(Design.text.challengeChains)
         $1
            .set(Design.state.label.descriptionMedium14)
            .textColor(Design.color.text)
            .numberOfLines(0)
      }
      .spacing(5)
      .padHorizontal(16)
      .padBottom(16)

   private lazy var chainParticipantsModel = ChainParticipantsModel<Asset>()

   override func start() {
      super.start()

      mainVM.navBar.titleLabel.text(Design.text.participants)
      mainVM.navBar.secondaryButtonHidden(true)
      mainVM
         .bodyStack
         .arrangedModels(
            descriptionBlock.lefted(),
            chainParticipantsModel.viewModel
         )

      on(\.input, self) {
         $0.chainParticipantsModel.startWithPayload($1)
         $0.descriptionBlock.models.right.text($1.name.unwrap)
      }

   }
}
