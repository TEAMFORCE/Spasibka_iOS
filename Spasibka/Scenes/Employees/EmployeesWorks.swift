//
//  EmployeesWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.02.2023.
//

import StackNinja


final class EmployeesFilter {
   var searchKey: String

   var departmentsArray: [SelectWrapper<DepartmentTree>]

   var filterInOffice: Int
   var filterOnHoliday: Int
   var filterFiredAt: Int

   init(searchKey: String,
        departmentsArray: [SelectWrapper<DepartmentTree>],
        filterInOffice: Int,
        filterOnHoliday: Int,
        filterFiredAt: Int)
   {
      self.searchKey = searchKey
      self.departmentsArray = departmentsArray

      self.filterInOffice = filterInOffice
      self.filterOnHoliday = filterOnHoliday
      self.filterFiredAt = filterFiredAt
   }
}

final class EmployeesWorksStorage: InitClassProtocol {
   var employees: [Colleague] = []

   var filter: EmployeesFilter?

   let paginator = PaginationSystem(pageSize: 20, startOffset: 1)
}

protocol EmployeesWorksProtocol: StoringWorksProtocol, Assetable where
   Asset: ASP, Store == EmployeesWorksStorage
{
   var apiUseCase: ApiUseCase<Asset> { get }
}

extension EmployeesWorksProtocol {
   var loadDepartmentsTree: Out<[DepartmentTree]> { .init { [weak self] work in
      self?.apiUseCase.getDepartmentsTree
         .doAsync()
         .onSuccess { (deptsTree: [DepartmentTree]) in
            let deptsArray = deptsTree
               .flatMap { $0.traverse() }
               .map {
                  SelectWrapper(value: $0)
               }
            Self.store.filter = EmployeesFilter(searchKey: "",
                                                departmentsArray: deptsArray,
                                                filterInOffice: 0,
                                                filterOnHoliday: 0,
                                                filterFiredAt: 0)
            work.success(deptsTree)
         }
         .onFail {
            work.fail()
         }
   } }

   var getEmployeesFilter: Out<EmployeesFilter?> { .init {
      $0.success(Self.store.filter)
   } }

   var setEmployeesFilter: In<EmployeesFilter?> { .init {
      Self.store.filter = $0.in
      Self.store.paginator.reInit()
      Self.store.employees = []

      $0.success()
   } }

   var loadEmployeesForCurrentFilter: VoidWork { .init { [weak self] work in
      let filter = Self.store.filter

      let deptsIds = filter?.departmentsArray
         .filter(\.isSelected)
         .map(\.value.id)

      let request = GetColleaguesRequest(
         name: filter?.searchKey ?? "",
         departments: deptsIds?.isEmpty == true ? nil : deptsIds,
         inOffice: filter?.filterInOffice ?? 0,
         onHoliday: filter?.filterOnHoliday ?? 0,
         firedAt: filter?.filterFiredAt ?? 0
      )
      
      Self.store.paginator
         .paginationForWork(self?.apiUseCase.getColleagues, withRequest: request)
         .doAsync()
         .onSuccess {
            if Self.store.employees.count < 20, $0.count > 0 {
               Self.store.employees = $0
            } else {
               Self.store.employees.append(contentsOf: $0)
            }
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getLoadedEmployees: Out<[Colleague]> { .init { work in
      print("count \(Self.store.employees.count)")
      work.success(Self.store.employees)
   }.retainBy(retainer) }

   var loadEmployeesForKey: In<String> { .init { [weak self] work in

      Self.store.filter?.searchKey = work.in
      Self.store.employees = []
      Self.store.paginator.reInit()

      self?.loadEmployeesForCurrentFilter
         .doAsync()
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getEmployeeByIndex: In<Int>.Out<Colleague> { .init { work in
      guard let index = work.input else { work.fail(); return }
      if Self.store.employees.indices.contains(index) {
         work.success(Self.store.employees[index])
      } else {
         work.fail()
      }
//      work.success(Self.store.employees[work.in])
   }.retainBy(retainer) }

   var getFilterStateActive: Out<Bool> { .init {
      guard let filter = Self.store.filter else { $0.success(false); return }

      if
         (filter.departmentsArray.contains { $0.isSelected })
         || filter.filterOnHoliday != 0
         || filter.filterInOffice != 0
         || filter.filterFiredAt != 0
      {
         $0.success(true)
      } else {
         $0.success(false)
      }
   }}
}

final class EmployeesWorks<Asset: ASP>: BaseWorks<EmployeesWorksStorage, Asset>, EmployeesWorksProtocol {
   let apiUseCase = Asset.apiUseCase
}
