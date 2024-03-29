//
//  CreateOrganizationScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.07.2023.
//

import StackNinja

enum CreateOrganizationInOut: InOutParams {
   typealias Input = CommunityParams
   typealias Output = CommunityParams
}

struct CreateOrganizationSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = ModalDoubleStackModel<Asset>
   }

   typealias InOut = CreateOrganizationInOut
}

final class CreateOrganizationScene<Asset: ASP>:
   BaseParamsScene<CreateOrganizationSceneParams<Asset>>
{
   private lazy var createOrganizationVM = CreateOrganizationVM<Design>()
      .setStates2(.fromSettings)

   override func start() {

      mainVM.bodyStack.arrangedModels(
         ScrollStackedModelY()
            .arrangedModels(
               createOrganizationVM
            )
      )
      mainVM.footerStack
         .arrangedModels(
            Spacer(16)
         )
      mainVM.title.text(Design.text.createCommunity)
      mainVM.closeButton.on(\.didTap, self) {
         $0.finishCanceled()
         $0.dismiss()
      }
      on(\.input, self) {
         $0.createOrganizationVM.setState(.initial($1))
      }

      createOrganizationVM.didTapStartButton
         .onSuccess(self) {
            $0.finishSucces($1)
            $0.dismiss()
         }
   }
}
