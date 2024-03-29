//
//  EmployeesScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.02.2023.
//

import StackNinja

struct EmployeesScenarioParams<Asset: ASP>: ScenarioParams {
   struct ScenarioInputEvents: ScenarioEvents {
      let didChangeSearchText: Out<String>
      let didSelectItemAtIndex: Out<Int>
      
      let didFilterTapped: VoidWork
      let didUpdateFilterState: Out<EmployeesFilter?>

      let requestPagination: VoidWork
   }

   typealias ScenarioModelState = EmployeesSceneState
   typealias ScenarioWorks = EmployeesWorks<Asset>
}

final class EmployeesScenario<Asset: ASP>: BaseParamsScenario<EmployeesScenarioParams<Asset>> {
   override func configure() {
      super.configure()

      start
         .doNext(works.loadDepartmentsTree)
         .doVoidNext(works.loadEmployeesForCurrentFilter)
         .doNext(works.getLoadedEmployees)
         .onSuccess(setState) { .presentEmployees($0) }
         .doVoidNext(works.getFilterStateActive)
         .onSuccess(setState) { .setFilterButtonActive($0) }
      
      events.didChangeSearchText
         .doNext(StringValidateWorker(isEmptyValid: true, minSymbols: 1))
         .doNext(works.loadEmployeesForKey, on: .globalBackground)
         .doNext(works.getLoadedEmployees)
         .onSuccess(setState) { .presentEmployees($0) }
      
      events.didSelectItemAtIndex
         .doNext(works.getEmployeeByIndex)
         .onSuccess(setState) { .presentEmployeeProfile($0) }
      
      events.didFilterTapped
         .doNext(works.getEmployeesFilter)
         .onSuccess(setState) { .presentFilter($0) }
      
      events.didUpdateFilterState
         .onSuccess(setState, .hidePopup)
         .doNext(works.setEmployeesFilter)
         .doVoidNext(works.getFilterStateActive)
         .onSuccess(setState) { .setFilterButtonActive($0) }
         .doVoidNext(works.loadEmployeesForCurrentFilter)
         .doNext(works.getLoadedEmployees)
         .onSuccess(setState) { .presentEmployees($0) }

      events.requestPagination
         .doNext(works.loadEmployeesForCurrentFilter)
         .doNext(works.getLoadedEmployees)
         .onSuccess(setState) { .presentEmployees($0) }
   }
}
