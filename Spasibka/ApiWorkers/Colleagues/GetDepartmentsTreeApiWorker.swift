//
//  GetDepartmentsTreeApiWorker.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.02.2023.
//

//struct Department: Codable {
//   let id: Int
//   let name: String
//   let children: [Department]
//}
//
//final class GetDepartmentsTreeApiWorker: BaseApiWorker<String, Department> {
//   override func doAsync(work: Wrk) {
//      guard
//         let token = work.input
//      else {
//         return
//      }
//      apiEngine?
//         .process(endpoint: SpasibkaEndpoints.GetStickerpacks(
//            headers: [Config.tokenHeaderKey: token])
//         )
//         .done { result in
//            let decoder = DataToDecodableParser()
//            guard
//               let data = result.data,
//               let department: Department = decoder.parse(data)
//            else {
//               work.fail()
//               return
//            }
//            work.success(department)
//         }
//         .catch { _ in
//            work.fail()
//         }
//   }
//}
