//
//  LogoutApiModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 26.07.2022.
//

import Foundation

final class LogoutApiWorker: BaseApiWorker<TokenRequest, Void> {
   override func doAsync(work: Wrk) {
      apiEngine?
         .process(endpoint: SpasibkaEndpoints.Logout())
         .done { _ in // result in
            print("Logout happened1")
            work.success()
         }
         .catch { _ in
            print("Logout failed")
            work.fail()
         }
   }
}
