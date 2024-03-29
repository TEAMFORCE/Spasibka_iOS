//
//  Categories.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja

enum Categories<Asset: ASP>: ScenaribleSceneParams {
   typealias Scenery = CategoriesScenario<Asset>
   typealias ScenarioWorks = CategoriesWorks<Asset>

   struct ScenarioInputEvents: ScenarioEvents {
      let payload: Out<CategoriesInput>

      let didTapEditCategories: VoidWork
      let didSelectCategory: Out<(isSelected: Bool, index: Int)>
      let didTapSaveButton: VoidWork

      let editCategoriesFinishWork = Work.void
   }

   enum ScenarioModelState {
      case present([SelectWrapper<CategoryData>])

      case loading
      case error
      case hereIsEmpty

      case finishWithSelected([CategoryData])

      case routeToEditCategories(ChallengeTemplatesScope)
   }

   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = ModalDoubleStackModel<Asset>
   }

   struct InOut: InOutParams {
      typealias Input = CategoriesInput
      typealias Output = [CategoryData]
   }
}

struct CategoriesInput {
   let scope: ChallengeTemplatesScope
   let selectedCategories: [CategoryData]
}
