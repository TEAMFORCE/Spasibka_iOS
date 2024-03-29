//
//  ChallengeTemplateCreate.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.07.2023.
//

import StackNinja
import UIKit

enum ChallengeTemplateCreateInput {
   case createTemplate(scope: ChallengeTemplatesScope)
   case updateTemplateWithTemplate(ChallengeTemplate, scope: ChallengeTemplatesScope)
}

enum ChallengeTemplateCreate<Asset: ASP>: ScenaribleSceneParams {
   typealias Scenery = ChallengeTemplateCreateScenario<Asset>
   typealias ScenarioWorks = ChallengeTemplateCreateWorks<Asset>

   struct ScenarioInputEvents: ScenarioEvents {
      let payload: Out<ChallengeTemplateCreateInput>

      let didTitleInputChanged: Out<String>
      let didDescriptionInputChanged: Out<String>

      let didSettingsPressed: Out<Void>
      let didCategoriesPressed: Out<Void>

      let didSendPressed: VoidWork

      let didSelectCategories = Out<[CategoryData]>()
      
      let didTapDelete: VoidWork
   }

   enum ScenarioModelState {
      case initCreateTemplate
      case initUpdateTemplateWithTemplate(ChallengeTemplate)

      case updateTitleTextField(String)
      case updateDescriptTextField(String)

      case awaitingState
      case readyToInput
      case errorState
      case dismissScene
      case cancelButtonPressed
      case setReady(Bool)

      case presentLoadedPhoto(UIImage?)

      case routeToSettingsScene(ChallengeSettings)
      case routeToCategories(CategoriesInput)

      case challengeCreated

      case presentCategoriesTags([CategoryData])
      
      case challengeDeleted
   }

   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = ModalDoubleStackModel<Asset>
   }

   struct InOut: InOutParams {
      typealias Input = ChallengeTemplateCreateInput
      typealias Output = Void
   }
}

