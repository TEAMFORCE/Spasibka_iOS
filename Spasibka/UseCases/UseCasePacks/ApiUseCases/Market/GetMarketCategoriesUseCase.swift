//
//  GetMarketCategoriesUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 24.01.2023.
//

import Foundation
import StackNinja

struct GetMarketCategoriesUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageWorker
   let getMarketCategoriesApiWorker: GetMarketCategoriesApiWorker

   var work: Work<Int, [Category]> {
      Work<Int, [Category]>() { work in
         safeStringStorage
            .doAsync(Config.tokenKey)
            .onFail {
               work.fail()
            }
            .doMap {
               guard let id = work.input else { return nil }
               return ($0, id)
            }
            .doNext(getMarketCategoriesApiWorker)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }
}
