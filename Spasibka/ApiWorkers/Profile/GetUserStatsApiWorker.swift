//
//  GetUserStatsApiWorker.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.12.2022.
//

import Foundation

struct UserStat: Codable {
   let id: Int // идентификатор ценности (0 - без ценности)
   let name: String // название ценности
   let amount: Float // количество ценностей
   let sum: Float // сумма спасибок
   let percentFromTotalAmount: Float // процент от общего числа количества ценностей
   let percentFromTotalSum: Float // процент от общей суммы спасибок

   enum CodingKeys: String, CodingKey {
      case id
      case name
      case amount
      case sum
      case percentFromTotalAmount = "percent_from_total_amount"
      case percentFromTotalSum = "percent_from_total_sum"
   }
}

final class GetUserStatsApiWorker: BaseApiWorker<String, [UserStat]> {
   override func doAsync(work: Wrk) {
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.GetUserStats(headers: [
            Config.tokenHeaderKey: work.input.unwrap,
         ]))
         .done { result in
            let decoder = DataToDecodableParser()

            guard
               let data = result.data,
               let balance: [UserStat] = decoder.parse(data)
            else {
               work.fail()
               return
            }

            work.success(result: balance)
         }
         .catch { _ in
            work.fail()
         }
   }
}
