//
//  CategoriesScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja

final class CategoriesScenario<Asset: ASP>: BaseScenarioExtended<Categories<Asset>> {
   override func configure() {
      super.configure()

      events.payload
         .doNext(works.saveInput)
         .doNext(works.loadCategories)
         .onSuccess(setState) { .present($0) }
         .onFail(setState, .error)

      events.didTapEditCategories
         .doNext(works.getCategoriesScope)
         .onSuccess(setState) { .routeToEditCategories($0) }

      events.editCategoriesFinishWork
         .doNext(works.loadCategories)
         .onSuccess(setState) { .present($0) }
         .onFail(setState, .error)

      events.didSelectCategory
         .doNext(works.toggleSelectionAtIndex)

      events.didTapSaveButton
         .doNext(works.getSelectedCategories)
         .onSuccess(setState) { .finishWithSelected($0) }
   }
}
