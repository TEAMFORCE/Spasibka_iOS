//
//  CategoriesEdit.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja

enum CategoriesEditInput {
   case topLevel(currentScope: ChallengeTemplatesScope)
   case subCategories(
      parentCategory: CategoryData,
      currentScope: ChallengeTemplatesScope
   )
}

enum CategoriesEdit<Asset: ASP>: ScenaribleSceneParams {
   typealias Scenery = CategoriesEditScenario<Asset>
   typealias ScenarioWorks = CategoriesEditWorks<Asset>

   struct ScenarioInputEvents: ScenarioEvents {
      let payload: Out<CategoriesEditInput>
      let didSelectScopeButton: Out<Button3Event>

      let didSelectCategory: Out<CategoryData>
      let didTapDeleteCatetegory: Out<CategoryData>

      let confirmDelete = Work.void
      let cancelDelete = Work.void

      let didTapCreateCategory: VoidWork
      let didFinishCreateNewCategory: Out<CreateCategoryResponse>

      let loadCategories = VoidWork()
   }

   enum ScenarioModelState {
      case title(String)
      case present([CategoryData], parentCategory: CategoryData?)
      case popCategories(Bool)

      case loading
      case error
      case hereIsEmpty
      case presentDeleteDialog(String)
      case deleteCategoryError

      case updateFilterButtonsForScope(ChallengeTemplatesScope)

      case routeToCategory(CategoriesEditInput)
      case routeToCreateCategory(CreateCategoryInput)
      case hideBottomPopup

      case clearAll
      case disableAdd
      case enableAdd
   }

   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = ModalDoubleStackModel<Asset>
   }

   struct InOut: InOutParams {
      typealias Input = CategoriesEditInput
      typealias Output = Void
   }
}
