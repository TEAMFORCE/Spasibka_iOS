//
//  SaveLoginResultsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 03.09.2023.
//

import StackNinja
import UIKit

protocol SaveLoginResultsWorksProtocol: WorksProtocol, ApiUseCaseable {}

extension SaveLoginResultsWorksProtocol {
   var setFcmToken: Work<Void, Void> { .init { [weak self] work in
      guard
         let deviceId = UIDevice.current.identifierForVendor?.uuidString,
         let currentFcmToken = UserDefaults.standard.string(forKey: "fcmToken")
      else {
         work.fail()
         return
      }

      let devicedToken = (deviceId + Config.urlBase).md5()
      let fcm = FcmToken(token: currentFcmToken, device: devicedToken)

      self?.apiUseCase.setFcmToken
         .doAsync(fcm)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }

   var saveLoginResults: MapIn<(token: String, sessionId: String)> { .init { [weak self] in
      self?.apiUseCase.safeStringStorage
         .set(.save((value: $0.token, key: Config.tokenKey)))
         .set(.save((value: $0.sessionId, key: "csrftoken")))

      UserDefaults.standard.setIsLoggedIn(value: true)
   }}
}

final class SaveLoginResultsWorks<Asset: ASP>: SaveLoginResultsWorksProtocol {
   let retainer = Retainer()
   let apiUseCase = Asset.apiUseCase
}
