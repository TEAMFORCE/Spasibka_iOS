//
//  GetStatByPeriodIdApiWorker.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.08.2022.
//

import Foundation
import StackNinja

//struct StatPeriodRequest {
//   let token: String
//   let id: Int
//}
// новые стракты потому что income и distr для
// user/balance и /user/stat/<int: id_периода> отличаются

struct Income2: Decodable {
   let amount: Int
   let frozen: Int
   let sent: Int
   let received: Int
   let cancelled: Int
   //usedForBonus будет после обновы
   let usedForBonus: Int?
   
   enum CodingKeys: String, CodingKey {
      case amount
      case frozen
      case sent
      case received
      case cancelled
      case usedForBonus = "used_for_bonus"
   }
}

struct Distr2: Codable {
   let amount: Int
   let expireDate: String
   let frozen: Int
   let sent: Int
   let received: Int
   let cancelled: Int
   let burnt: Int
   
   enum CodingKeys: String, CodingKey {
      case amount
      case expireDate = "expire_date"
      case frozen
      case sent
      case received
      case cancelled
      case burnt
   }
}


struct PeriodStat: Decodable {
   let income: Income2
   let distr: Distr2
   let bonus: Int
}

final class GetStatByPeriodIdApiWorker: BaseApiWorker<RequestWithId, PeriodStat> {
   override func doAsync(work: Work<RequestWithId, PeriodStat>) {
      guard
         let RequestWithId = work.input
      else {
         work.fail()
         return
      }
      
      let endpoint = SpasibkaEndpoints.StatPeriodById(
         id: String(RequestWithId.id),
         headers: [Config.tokenHeaderKey: RequestWithId.token,]
      )
      
      apiEngine?
         .process(endpoint: endpoint)
         .done { result in
            let decoder = DataToDecodableParser()
            guard
               let data = result.data,
               let periodStat: PeriodStat = decoder.parse(data)
            else {
               work.fail()
               return
            }
            work.success(result: periodStat)
         }
         .catch { _ in
            work.fail()
         }
   }
}
