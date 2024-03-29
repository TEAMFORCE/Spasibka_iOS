//
//  EmployeesFilterWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.02.2023.
//

import CoreGraphics
import StackNinja

final class EmployeesFilterWorksStorage: InitProtocol {
   var filter: EmployeesFilter?
}

protocol EmployeesFilterWorksProtocol: StoringWorksProtocol, Assetable
   where Asset: AssetProtocol, Store == EmployeesFilterWorksStorage
{}

extension EmployeesFilterWorksProtocol {
   var setupFilterData: In<EmployeesFilter?> { .init { work in
      Self.store.filter = work.in

      work.success()
   } }

   
   var getFilter: Out<EmployeesFilter?> { .init {
      $0.success(Self.store.filter)
   }}

   var getDepartmentsList: Out<[SelectWrapper<DepartmentTree>]> { .init { work in
      work.success(Self.store.filter?.departmentsArray ?? [])
   }.retainBy(retainer) }

   var updateFilterSelectAtIndex: In<Int>.Out<(item: SelectWrapper<DepartmentTree>, index: Int)> { .init { work in
      
      guard let item = Self.store.filter?.departmentsArray[work.in] else {
         work.fail()
         return
      }
      
      item.isSelected = !item.isSelected

      work.success((item: item, index: work.in))
   }.retainBy(retainer) }

   var clearFilter: Out<EmployeesFilter?> { .init {
      Self.store.filter?.departmentsArray.forEach { $0.isSelected = false }
      Self.store.filter?.filterFiredAt = 0
      Self.store.filter?.filterInOffice = 0
      Self.store.filter?.filterOnHoliday = 0
      $0.success(Self.store.filter)
   }}
   
   var setFiredAtTurned: In<Bool> { .init { 
      Self.store.filter?.filterFiredAt = $0.in ? 1 : 0
   }}
   
   var setInOfficeTurned: In<Bool> { .init { 
      Self.store.filter?.filterInOffice = $0.in ? 1 : 0
   }}
   
   var setOnHolidayTurned: In<Bool> { .init { 
      Self.store.filter?.filterOnHoliday = $0.in ? 1 : 0
   }}
}

final class EmployeesFilterWorks<Asset: ASP>: BaseWorks<EmployeesFilterWorksStorage, Asset>,
   EmployeesFilterWorksProtocol
{}
