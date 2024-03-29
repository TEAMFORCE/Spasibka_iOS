//
//  ChallengeChainsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.02.2024.
//

import StackNinja

enum ChallengeChainsSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyFooterStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class ChallengeChainsScene<Asset: ASP>: BaseParamsScene<ChallengeChainsSceneParams<Asset>> {
   private lazy var challengeChainsModel = ChallengeChainsMainViewModel<Asset>()

   override func start() {
      super.start()

      mainVM.navBar
         .titleLabel.text(Design.text.challengeChains)

      mainVM.bodyStack
         .arrangedModels(challengeChainsModel)
         .padding(.verticalOffset(16))

      vcModel?.view.backgroundColor = Design.color.transparent

      challengeChainsModel.scenario.configureAndStart()
   }
}
