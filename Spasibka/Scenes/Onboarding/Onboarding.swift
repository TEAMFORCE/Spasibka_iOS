//
//  Onboarding.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import StackNinja

enum Onboarding<Asset: ASP>: ScenaribleSceneParams {
   typealias Scenery = OnboardingScenario<Asset>
   typealias ScenarioWorks = OnboardingWorks<Asset>

   struct ScenarioInputEvents: ScenarioEvents {
      let input: Out<String>

      let didTapCreateCommunity: VoidWork
      let didTapJoinCommunity: VoidWork

      let didEditingCreateCommunityTitle: Out<String>
      let didEditingJoinCommunitySharedKey: Out<String>

      let didTapContinueCreateCommunity: VoidWork
      let didTapContinueJoinCommunity: VoidWork

      let didTapCancelPopups: VoidWork
   }

   enum ScenarioModelState {
      case initial
      case loading
      case loadingSuccess
      case loadingError

      case presentCreateCommunityPopup
      case presentJoinCommunityPopup
      case hidePopups

      case createCommunityPopupState(buttonEnabled: Bool, text: String)
      case joinCommunityPopupState(buttonEnabled: Bool, text: String)

      case routeToConfigureCommunityWithName(String)
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

