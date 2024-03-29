//
//  MakeCookiedTokenHeader.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.06.2023.
//

import Foundation

func makeCookiedTokenHeader(_ token: String) -> [String: String] {
   let cookieName = "csrftoken"

   guard
      let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName })
   else {
      assertionFailure("No csrf cookie in func makeCookiedTokenHeader()")
      return [:]
   }
   return [
      Config.tokenHeaderKey: token,
      "X-CSRFToken": cookie.value,
   ]
}
