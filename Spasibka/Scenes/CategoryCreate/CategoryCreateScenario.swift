//
//  CategoryCreateScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja

struct CreateCategoryScenarioInput: ScenarioEvents {
   let initial: Out<CreateCategoryInput>

   let didEditingCategoryName: Out<String>
   let didSelectParentCategory: Out<(isSelected: Bool, index: Int)>

   let didTapCreateCategory: VoidWork

   let setParentCategory: Out<CategoryData?> = .init()
}

final class CreateCategoryScenario<Asset: ASP>:
   BaseWorkableScenario<CreateCategoryScenarioInput, CreateCategoryState, CreateCategoryWorks<Asset>>
{
   override func configure() {
      super.configure()

      events.initial
         .doNext(works.saveInitialData)
         .onSuccess(setState) { .presentParentCategories($0) }
         .doVoidNext(works.getSelectedCategoriesCount)
         .onSuccess(setState) { .updateSelectedCount($0) }

      events.didSelectParentCategory
         .doNext(works.updateCategorySelection)
         .doNext(works.getSelectedCategoriesCount)
         .onSuccess(setState) { .updateSelectedCount($0) }

      events.didEditingCategoryName
         .doNext(StringValidateWorker(isEmptyValid: false, minSymbols: 1))
         .onSuccess(setState, .createButtonEnabled)
         .onFail(setState, .createButtonDisabled)
         .doNext(works.updateCategoryName)

      events.didTapCreateCategory
         .onSuccess(setState, .loading)
         .doNext(works.createCategory)
         .onSuccess(setState) { .finish($0) }
         .onFail(setState, .error)

      events.setParentCategory
         .doNext(works.setParentCategory)
         .doNext(works.getCategories)
         .onSuccess(setState) { .presentParentCategories($0) }
   }
}
