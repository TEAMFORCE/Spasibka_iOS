//
//  LoginUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.08.2022.
//

import Foundation
import StackNinja

struct LoginRequest {
   let loginName: String
   let sharedKey: String?
}

struct LoginUseCase: UseCaseProtocol {
   var apiEngine: ApiWorksProtocol?

   var work: Work<LoginRequest, Auth2Result> { .init { work in
      let request = work.in
      let loginName = request.loginName
      let sharedKey = request.sharedKey

      HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)

      var body: [String: String] = ["type": "authorize",
                                    "login": loginName]

      if let sharedKey {
         body["shared_key"] = sharedKey
      }

      apiEngine?
         .process(endpoint: SpasibkaEndpoints.AuthEndpoint(
            body: body
         ))
         .onSuccess { result in
            if (result.response?.headerValueFor("login")) != nil {
               guard let soloOrg = SoloOrgResult(result.data) else {
                  work.fail()
                  return
               }

               work.success(result: .existUser(soloOrg.organizations))
            } else if let xCode = result.response?.headerValueFor("X-Code") {
               let xId: String?
               let account: Account?
               if let telegramHeaderValue = result.response?.headerValueFor("X-Telegram") {
                  xId = telegramHeaderValue
                  account = .telegram
               } else {
                  xId = result.response?.headerValueFor("X-Email")
                  account = .email
               }

               guard let xId = xId, let account = account else { return }

               work.success(result: .auth(AuthResult(xId: xId, xCode: xCode, account: account)))
            } else if let body = AuthNewUserResult(result.data) {
               work.success(.newUser(body))
            }
         }
         .onFail { (error: ApiEngineError) in
            work.fail(error)
            work.fail()
         }
   } }
}
