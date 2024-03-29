//
//  ChalengeFGroupScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.02.2024.
//

import StackNinja

enum ChallengeMenuSceneParamsOutput {
   case createChallenge
   case templates
   case cancel
}

enum ChallengeMenuSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = VStackModel
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class ChallengeMenuScene<Asset: ASP>: BaseParamsScene<ChallengeMenuSceneParams<Asset>> {
   override func start() {
      super.start()

      mainVM
         .set(Design.state.stack.bottomButtonsPanel)
      .arrangedModels(
         Design.button.default
            .title(Design.text.createChallenge)
            .setNeedsStoreModelInView()
            .on(\.didTap, self) {
               $0.dismiss()
               Asset.router?.route(.push, scene: \.challengeCreate, payload: .createChallenge)
            },
         Design.button.default
            .title(Design.text.сhallengeTemplates)
            .setNeedsStoreModelInView()
            .on(\.didTap, self) {
               $0.dismiss()
               Asset.router?.route(.push, scene: \.challengeTemplates)
            },
         Design.button.brandSecondary
            .title(Design.text.cancel)
            .setNeedsStoreModelInView()
            .on(\.didTap, self) {
               $0.dismiss()
            },
         Spacer()
      )
   }
}

enum ChalengeGroupSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentInitial>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class ChalengeGroupScene<Asset: ASP>: BaseParamsScene<ChalengeGroupSceneParams<Asset>> {
   private lazy var challengesGroupVM = ChallengeGroupSceneViewModel<Asset>()

   override func start() {
      super.start()

      mainVM.navBar.titleLabel.text(Design.text.challenges)
      mainVM.navBar.menuButton.image(Design.icon.threeDotsCircle)
      mainVM.bodyStack.arrangedModels(challengesGroupVM)

      challengesGroupVM.scenario.configureAndStart()

      mainVM.navBar.menuButton.on(\.didTap) {
         Asset.router?.route(.bottomScheet, scene: \.challengesMenu)
      }
      
      vcModel?.on(\.viewWillAppearByBackButton, self) {
         $0.challengesGroupVM.challengesScene.scenario.events.reloadChallenges.sendAsyncEvent()
      }
   }
}
