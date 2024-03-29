//
//  CategoriesEditWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja

final class CategoriesEditStore: InitClassProtocol {
   var scope: ChallengeTemplatesScope = .common
   var categories: [CategoryData] = []
   var mode: Mode = .topLevel
   var parentCategory: CategoryData?
   enum Mode {
      case topLevel
      case subCategories
   }
}

final class CategoriesEditWorks<Asset: ASP>: BaseWorks<CategoriesEditStore, Asset> {
   private let apiUseCase = Asset.apiUseCase

   var saveInput: In<CategoriesEditInput> { .init { work in
      let input = work.in
      switch input {
      case let .topLevel(scope):
         Self.store.mode = .topLevel
         Self.store.scope = scope
         work.success()
      case let .subCategories(parentCategory, scope):
         Self.store.mode = .subCategories
         Self.store.scope = scope
         Self.store.parentCategory = parentCategory
         Self.store.categories = parentCategory.children ?? []
         work.success()
      }
   }}

   var checkIsTopLevel: VoidWork { .init { work in
      if Self.store.mode == .topLevel {
         work.success()
      } else {
         work.fail((name: Self.store.parentCategory?.name ?? "", subCategories: Self.store.categories))
      }
   }}

   var getCurrentScope: Out<ChallengeTemplatesScope> { .init { work in
      work.success(Self.store.scope)
   }}

   var setCurrentScope: In<Button3Event> { .init { work in
      switch work.in {
      case .didTapButton1:
         Self.store.scope = .my
      case .didTapButton2:
         Self.store.scope = .ours
      case .didTapButton3:
         Self.store.scope = .common
      }
      work.success()
   }}

   var loadCategories: Out<[CategoryData]> { .init { [weak self] work in
      switch Self.store.mode {
      case .topLevel:
         self?.apiUseCase.getCategories
            .doAsync(Self.store.scope)
            .onSuccess {
               Self.store.categories = $0.data
               work.success($0.data)
            }
            .onFail { work.fail() }
      case .subCategories:
         work.success(Self.store.categories)
      }
   } }

   var getCreateCategoryInput: Out<CreateCategoryInput> { .init { work in
      work.success(.init(
         categories: Self.store.categories,
         scope: Self.store.scope,
         parentCategory: Self.store.parentCategory
      ))
      print("parent \(Self.store.parentCategory)")
   }.retainBy(retainer) }

   var getCategoryByIndex: In<Int>.Out<CategoryData> { .init { work in
      let category = Self.store.categories[work.in]
      work.success(category)
   } }

//   var getSubCategoriesForIndexWithScope: In<Int>.Out<CategoriesEditInput> { .init { work in
//      work.success(
//         .subCategories(
//            parentCategory: Self.store.categories[work.in],
//            currentScope: Self.store.scope
//         )
//      )
//   } }

   var getSubCategoriesForCategory: In<CategoryData>.Out<[CategoryData]> { .init { work in
      work.success(work.in.children ?? [])
   } }

   var setParentCategory: InOut<CategoryData> { .init { work in
      Self.store.parentCategory = work.in
      work.success(work.in)
   } }


//   var getCategoryName: In<Int>.Out<String> { .init { work in
//      let category = Self.store.categories[work.in]
//      work.success(category.name)
//   } }

   var mapCategoryName: In<CategoryData>.Out<String> { .init { work in
      let category = work.in
      work.success(category.name)
   } }

//   var deleteCategoryAtIndex: In<Int> { .init { [weak self] work in
//      let index = work.in
//      let category = Self.store.categories[index]
//      self?.apiUseCase.deleteCategory
//         .doAsync(category.id)
//         .onSuccess {
//            if Self.store.mode == .subCategories {
//               Self.store.categories.remove(at: index)
//            }
//            work.success()
//         }
//         .onFail { work.fail() }
//   } }

   var deleteCategory: In<CategoryData> { .init { [weak self] work in
      let category = work.in
      self?.apiUseCase.deleteCategory
         .doAsync(category.id)
         .onSuccess {
            if Self.store.mode == .subCategories,
               let index = (Self.store.categories
                  .firstIndex { $0.id == category.id })
            {
               Self.store.categories.remove(at: index)
            }
            work.success()
         }
         .onFail { work.fail() }
   } }

   var addNewCategory: In<CreateCategoryResponse> { .init { work in
      let response = work.in
      if Self.store.mode == .subCategories, response.upperSection == Self.store.parentCategory?.id {
         let newCategory = CategoryData(
            id: response.id ?? 0,
            name: response.name,
            children: []
         )
         Self.store.categories.append(newCategory)
      }
      work.success()
   } }
}
