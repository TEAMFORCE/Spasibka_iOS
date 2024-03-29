//
//  EmployeesFilterScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.02.2023.
//

import StackNinja

struct EmployeesFilterScenarioEvents: ScenarioEvents {  
   
   let initializeWithFilter: Out<EmployeesFilter?>
   
   let didSelectFilterItemAtIndex: Out<Int>
   
   let firedAtSwitched: Out<Bool>
   let inOfficeSwitched: Out<Bool>
   let onHolidaySwitched: Out<Bool>
   
   let didApplyFilterPressed: VoidWork
   let didClearFilterPressed: VoidWork
}

struct EmployeesFilterScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = EmployeesFilterScenarioEvents
   typealias ScenarioModelState = EmployeesFilterSceneState
   typealias ScenarioWorks = EmployeesFilterWorks<Asset>
}

final class EmployeesFilterScenario<Asset: ASP>: BaseParamsScenario<EmployeesFilterScenarioParams<Asset>> {
   
   override func configure() {
      super.configure()
      
      events.initializeWithFilter
         .doNext(works.setupFilterData)
         .doNext(works.getDepartmentsList)
         .onSuccess(setState) { .initial($0) }
         .doVoidNext(works.getFilter)
         .onSuccess(setState) { .setupFilterFace($0) }
      
      events.didSelectFilterItemAtIndex
         .doNext(works.updateFilterSelectAtIndex)
         .onSuccess(setState) { .updateFilterItemAtIndex(item: $0, index: $1) }
      
      events.firedAtSwitched
         .doNext(works.setFiredAtTurned)
      
      events.inOfficeSwitched
         .doNext(works.setInOfficeTurned)
      
      events.onHolidaySwitched
         .doNext(works.setOnHolidayTurned)
      
      events.didApplyFilterPressed
         .doNext(works.getFilter)
         .onSuccess(setState) { .applyFilter($0) }
      
      events.didClearFilterPressed
         .doNext(works.clearFilter)
         .onSuccess(setState) { .applyFilter($0) }
   }
}
