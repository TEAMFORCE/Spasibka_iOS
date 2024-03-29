//
//  ChallengesScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.02.2024.
//

import StackNinja

enum ChallengesSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyFooterStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class ChallengesScene<Asset: ASP>: BaseParamsScene<ChallengesSceneParams<Asset>> {
   private lazy var challengesModel = ChallengesMainViewModel<Asset>(isFilterButtonsEnabled: true)

   private lazy var didChallengeCreated = Out<FinishEditChallengeEvent>()
      .onSuccess(self) {
         $0.challengesModel.scenarioStart()
      }

   override func start() {
      super.start()

      mainVM.navBar.titleLabel
         .text(Design.text.challenges)
      mainVM.navBar.menuButton
         .image(Design.icon.tablerPlus, color: Design.color.iconSecondary)
         .on(\.didTap, self) {
            Asset.router?.route(
               .push,
               scene: \.challengeCreate,
               payload: .createChallenge,
               finishWork: $0.didChallengeCreated
            )
         }

      mainVM.bodyStack
         .arrangedModels(challengesModel)
         .padding(.verticalOffset(16))

//      mainVM.footerStack
//         .arrangedModels([])

      vcModel?.view.backgroundColor = Design.color.transparent

      challengesModel.scenario.configureAndStart()
      
      vcModel?.on(\.viewWillAppearByBackButton, self) {
         $0.challengesModel.scenario.events.reloadChallenges.sendAsyncEvent()
      }

   }
}
