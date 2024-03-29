//
//  GetDepartmentsTreeUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.02.2023.
//

import ReactiveWorks

protocol Tree {
   associatedtype T: Tree
   var children: [T]? { get }
   var depth: Int? { get set }
}

extension Tree where T == Self {
   func traverse(depth: Int = 0) -> [T] {
      var result: [T] = []
      var toAppend = self
      toAppend.depth = depth
      result.append(toAppend)
      if let children {
         for child in children {
            print("depth \(depth)")
            result.append(contentsOf: child.traverse(depth: depth + 1))
         }
      }
      return result
   }
}

final class DepartmentTree: Codable, Tree {
   var depth: Int?
   
   let id: Int
   let name: String
   let children: [DepartmentTree]?
}

struct GetDepartmentsTreeUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let apiEngine: ApiEngineProtocol

   var work: Work<Void, [DepartmentTree]> {
      .init { work in

         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .onSuccess { token in
               apiEngine
                  .process(endpoint: SpasibkaEndpoints.GetDepartmentsTree(
                     headers: [Config.tokenHeaderKey: token])
                  )
                  .done { result in
                     guard
                        let data = result.data,
                        let department = [DepartmentTree](data)
                     else {
                        work.fail()
                        return
                     }
                     work.success(department)
                  }
                  .catch { _ in
                     work.fail()
                  }
            }
      }
   }
}
