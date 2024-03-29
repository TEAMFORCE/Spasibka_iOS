//
//  CategoriesWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.07.2023.
//

import StackNinja

final class CategoriesStore: InitClassProtocol {
   var scope: ChallengeTemplatesScope = .common
   var categories: [SelectWrapper<CategoryData>] = []
}

final class CategoriesWorks<Asset: ASP>: BaseWorks<CategoriesStore, Asset> {
   private let apiUseCase = Asset.apiUseCase

   var saveInput: In<CategoriesInput> { .init { work in
      Self.store.scope = work.in.scope
      Self.store.categories = work.in.selectedCategories.map { .init(value: $0, isSelected: true) }
      work.success()
   }}

   var loadCategories: Out<[SelectWrapper<CategoryData>]> { .init { work in
      self.apiUseCase.getCategories
         .doAsync(Self.store.scope)
         .onSuccess {
            let selected = Self.store.categories.filter(\.isSelected)
            Self.store.categories = $0.data
               .map { $0.traverse() }
               .flatMap { $0 }
               .map { value in
                  SelectWrapper(
                     value: value,
                     isSelected: selected
                        .first(where: { value.id == $0.value.id })
                        .map(\.isSelected) ?? false
                  )
               }

            work.success(Self.store.categories)
         }
         .onFail { work.fail() }
   } }

   var getCategoriesScope: Out<ChallengeTemplatesScope> { .init { work in
      work.success(Self.store.scope)
   }.retainBy(retainer) }

   var toggleSelectionAtIndex: In<(isSelected: Bool, index: Int)>.Out<Void> { .init { work in
      let index = work.in
      Self.store.categories[index.index].isSelected = work.in.isSelected
      work.success()
   } }

   var getSelectedCategories: Out<[CategoryData]> { .init { work in
      let selectedCategories = Self.store.categories
         .filter(\.isSelected)
         .map(\.value)

      work.success(selectedCategories)
   } }

}
