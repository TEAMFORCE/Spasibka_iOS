//
//  CategoriesEditScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja

final class CategoriesEditScenario<Asset: ASP>: BaseScenarioExtended<CategoriesEdit<Asset>> {
   override func configure() {
      super.configure()

      events.payload
         .doNext(works.saveInput)
         .doNext(works.checkIsTopLevel)
         .onFail(setState) { (name: String, subCategories: [CategoryData]) in
            [.title(name), .present(subCategories, parentCategory: nil)]
         }
         .doNext(works.getCurrentScope)
         .onSuccess(setState) { .updateFilterButtonsForScope($0) }
         .doSendVoidEvent(events.loadCategories)

      events.didSelectScopeButton
         .onSuccess(setState) {
            switch $0 {
            case .didTapButton1:
               return .enableAdd
            case .didTapButton2:
               return .enableAdd
            case .didTapButton3:
               return .disableAdd
            }
         }
         .onSuccess(setState) { _ in [.clearAll, .loading] }
         .doNext(works.setCurrentScope)

         .doSendVoidEvent(events.loadCategories)

      events.didSelectCategory
         .doNext(works.setParentCategory)
         .onSuccess(setState) { .present($0.children ?? [], parentCategory: $0) }

//      events.didSelectCategoryAtIndex
//         .doNext(works.getSubCategoriesForIndexWithScope)
//         .onSuccess(setState) { .routeToCategory($0) }

      events.didTapCreateCategory
         .doNext(works.getCreateCategoryInput)
         .onSuccess(setState) { .routeToCreateCategory($0) }

      events.didFinishCreateNewCategory
         .onSuccess(setState, .clearAll)
         .doNext(works.addNewCategory)
         .doSendVoidEvent(events.loadCategories)

      events.loadCategories
         .doNext(works.loadCategories)
         .onSuccess(setState) { .present($0, parentCategory: nil) }
         .onFail(setState, .error)

      // MARK: - deleting

      events.didTapDeleteCatetegory
         .doNext(works.mapCategoryName)
         .onSuccess(setState) { .presentDeleteDialog($0) }

      Work.startVoid.retainBy(works.retainer)
         .doCombine(events.didTapDeleteCatetegory, events.confirmDelete)
         .doMap { $0.0 }
         .doNext(works.deleteCategory)
         .onFail(setState, .deleteCategoryError)
         .onSuccess(setState, .clearAll)
         .doSendVoidEvent(events.loadCategories)

   }
}
