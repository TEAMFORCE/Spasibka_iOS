//
//  ChallengeReactionsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.02.2024.
//

import StackNinja

enum ReactionsSceneInput {
   case Challenge(Int)
   case Transaction(Int)
   case ReportId(Int)
}
struct ChallengeReactionsSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentBottomScheet>
   }

   struct InOut: InOutParams {
      typealias Input = ReactionsSceneInput
      typealias Output = Void
   }
}

final class ChallengeReactionsScene<Asset: AssetProtocol>: BaseParamsScene<ChallengeReactionsSceneParams<Asset>> {
   private lazy var model = ChallengeReactionsModel<Asset>()

   override func start() {
      super.start()

      mainVM.navBar.titleLabel.text(Design.text.liked)
      mainVM.bodyStack
         .arrangedModels(model.viewModel)

      on(\.input, self) {
         $0.model.startWithPayload($1)
      }
   }
}

