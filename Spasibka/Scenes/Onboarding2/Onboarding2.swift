//
//  Onboarding2.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import StackNinja

enum Onboarding2<Asset: ASP>: ScenaribleSceneParams {
   typealias Scenery = Onboarding2Scenario<Asset>
   typealias ScenarioWorks = Onboarding2Works<Asset>

   struct ScenarioInputEvents: ScenarioEvents {
      let input: Out<String>

      let didTapStartButton: Out<CommunityParams>
//      let didTapConfigModeButton: VoidWork
   }

   enum ScenarioModelState {
      case initial
      case configMode(automatic: Bool)
      case routeToFinishOnboarding(inviteLink: String)

      case loadingError
      case loading
   }

   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = BrandDoubleStackVM<Asset.Design>
   }

   struct InOut: InOutParams {
      typealias Input = String
      typealias Output = Void
   }
}

