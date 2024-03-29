//
//  CategoryCreateWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja

final class CreateCategoryStore: InitClassProtocol {
   var parentCategory: CategoryData?
   var parentCategories: [SelectWrapper<CategoryData>] = []
   var categoryName: String = ""
   var scope: ChallengeTemplatesScope = .common
}

final class CreateCategoryWorks<Asset: ASP>: BaseWorks<CreateCategoryStore, Asset> {
   private let apiUseCase = Asset.apiUseCase

   var saveInitialData: In<CreateCategoryInput>.Out<[SelectWrapper<CategoryData>]> { .init { work in
     // let parentCategory = work.in.parentCategory
      let parentCategories = work.in.categories
         .map { $0.traverse() }
         .flatMap { $0 }
         .map { SelectWrapper(value: $0, isSelected: $0.id ==  Self.store.parentCategory?.id) }

      Self.store.scope = work.in.scope
     // Self.store.parentCategory = parentCategory
      Self.store.parentCategories = parentCategories
      work.success(Self.store.parentCategories)
   } }

   var setParentCategory: In<CategoryData?>.Out<Void> { .init { work in
      Self.store.parentCategories.forEach { $0.isSelected = false }
      Self.store.parentCategory = work.in
      if let index = (Self.store.parentCategories.firstIndex {
         $0.value.id == work.in?.id
      }) {
         print("parent \(work.in?.name)")
         Self.store.parentCategories[index].isSelected = true
      }
      work.success()
   } }

   var getCategories: Out<[SelectWrapper<CategoryData>]> { .init { work in
      let categories = Self.store.parentCategories
      work.success(categories)
   } }

   var getSelectedCategories: Out<[CategoryData]> { .init { work in
      let selectedCategories = Self.store.parentCategories
         .filter(\.isSelected)
         .map(\.value)

      work.success(selectedCategories)
   } }

   var getSelectedCategoriesCount: Out<Int> { .init { work in
      let selectedCategoriesCount = Self.store.parentCategories
         .filter(\.isSelected)
         .count

      work.success(selectedCategoriesCount)
   } }

   var updateCategoryName: In<String> { .init { work in
      Self.store.categoryName = work.in
      work.success()
   } }

   var updateCategorySelection: In<(isSelected: Bool, index: Int)>.Out<Void> { .init { work in
      let (isSelected, index) = work.in
      Self.store.parentCategories[index].isSelected = isSelected
      work.success()
   } }

   var createCategory: Out<CreateCategoryResponse> { .init { [weak self] work in
      var parents = Self.store.parentCategories
         .filter(\.isSelected)
         .map(\.value.id)
//      if let parentId = Self.store.parentCategory?.id {
//         parents.insert(parentId, at: 0)
//      }
      self?.apiUseCase.createCategory
         .doAsync(CreateCategoryRequestBody(
            name: Self.store.categoryName,
            upperSections: parents,
            scope: Self.store.scope.rawValue
         ))
         .onSuccess { response in
            work.success(response)
         }
         .onFail { work.fail() }
   } }
}
