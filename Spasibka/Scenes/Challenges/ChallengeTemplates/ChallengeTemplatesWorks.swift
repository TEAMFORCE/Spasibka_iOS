//
//  ChallengeTemplatesWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.05.2023.
//

import StackNinja

final class ChallengeTemplatesStore: InitClassProtocol {
   private var myTemplates = [ChallengeTemplate]()
   private var oursTemplates = [ChallengeTemplate]()
   private var commonTemplates = [ChallengeTemplate]()

   private let myPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
   private let oursPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
   private let commonPaginator = PaginationSystem(pageSize: 20, startOffset: 1)

   var paginatorForCurrentFilter: PaginationSystem {
      switch scope {
      case .my:
         return myPaginator
      case .ours:
         return oursPaginator
      case .common:
         return commonPaginator
      }
   }

   var templatesForCurrentFilter: UnsafeMutablePointer<[ChallengeTemplate]> {
      switch scope {
      case .my:
         return withUnsafeMutablePointer(to: &myTemplates) { $0 }
      case .ours:
         return withUnsafeMutablePointer(to: &oursTemplates) { $0 }
      case .common:
         return withUnsafeMutablePointer(to: &commonTemplates) { $0 }
      }
   }

   func resetLoadedTemplates() {
      myTemplates.removeAll()
      oursTemplates.removeAll()
      commonTemplates.removeAll()

      myPaginator.reInit()
      oursPaginator.reInit()
      commonPaginator.reInit()
   }

   var scope = ChallengeTemplatesScope.my
}

final class ChallengeTemplatesWorks<Asset: ASP>: BaseWorks<ChallengeTemplatesStore, Asset> {
   private lazy var apiUseCase = Asset.apiUseCase

   var setCurrentFilterMy: VoidWork { .init {
      Self.store.scope = .my
      $0.success()
   }}

   var setCurrentFilterOurs: VoidWork { .init {
      Self.store.scope = .ours
      $0.success()
   }}

   var setCurrentFilterCommon: VoidWork { .init {
      Self.store.scope = .common
      $0.success()
   }}

   var loadTemplatesForCurrentFilter: VoidWork { .init { [weak self] work in
      guard let self else { work.fail(); return }

      let filter = Self.store.scope.rawValue
      Self.store.paginatorForCurrentFilter
         .paginationForWork(self.apiUseCase.getChallengeTemplates, withRequest: filter)
         .doAsync()
         .onSuccess {
            Self.store.templatesForCurrentFilter.pointee.append(contentsOf: $0)
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }

   var getTemplatesForCurrentFilter: Out<[ChallengeTemplate]> { .init {
      $0.success(Self.store.templatesForCurrentFilter.pointee)
   }}

   var getFilteredTemplatesForCurrentFilter: In<String>.Out<[ChallengeTemplate]> { .init { work in
      let key = work.in

      guard key.isEmpty == false else {
         work.success(Self.store.templatesForCurrentFilter.pointee)
         return
      }

      let filtered = Self.store.templatesForCurrentFilter.pointee.filter {
         $0.name.unwrap.localizedCaseInsensitiveContains(key)
         || $0.description.unwrap.localizedCaseInsensitiveContains(key)
      }

      work.success(filtered)
   }}

   var getTemplateByIndex: In<Int>.Out<(ChallengeTemplate, scope: ChallengeTemplatesScope)> { .init { work in
      work.success((Self.store.templatesForCurrentFilter.pointee[work.in], scope: Self.store.scope))
   }}

   var resetTemplates: VoidWork { .init {
      Self.store.resetLoadedTemplates()
      $0.success()
   } }

   var getCurrentScope: Out<ChallengeTemplatesScope> { .init {
      $0.success(Self.store.scope)
   } }
}
