//
//  Config.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.08.2022.
//

import Foundation
import StackNinja
import UIKit

enum Toggle {
   static let isBenefitsHidden = true
   static let isColorBrandingDisabled = false
}

enum Config {
   static let tokenKey = "token"
   static let tokenHeaderKey = "Authorization"
   static let vkAccessTokenKey = "vkAccessTokenKey"

   #if DEBUG
   static var urlBase = UserDefaults.standard.loadString(forKey: .urlBase) ?? SecretConfig.urlBaseDebug
   #else
   static var urlBase = UserDefaults.standard.loadString(forKey: .urlBase) ?? SecretConfig.urlBaseProduction
   #endif

   static func setDebugMode(_ isDebug: Bool) {
      urlBase = isDebug ? SecretConfig.urlBaseDebug : SecretConfig.urlBaseProduction
      UserDefaults.standard.saveString(urlBase, forKey: .urlBase)
   }

   static var isDebugServer: Bool {
      urlBase == SecretConfig.urlBaseDebug
   }

   static let isPlaygroundScene = false

   static let isDebugApiRequestLog = true
   static let isDebugApiRequestBodyLog = true
   static let isDebugApiResponseStatusCodeLog = true
   static let isDebugApiResponseLog = true
   static let isDebugApiResponseBodyLog = true

   #if DEBUG
      static let httpTimeout: TimeInterval = 20
   #else
      static let httpTimeout: TimeInterval = 30
   #endif

   static let baseAspectWidth: CGFloat = 360
   static let baseApsectHeight: CGFloat = 812
   static var sizeAspectCoeficient: CGFloat { UIScreen.main.bounds.width / baseAspectWidth }
   static var heightAspectCoeficient: CGFloat { UIScreen.main.bounds.height / baseApsectHeight }

   static let imageSendSize: CGFloat = 1920
   static let avatarSendSize: CGFloat = 1920

   static let colorSchemeKey = "colorSchemeKey"
   static let isNeedOrganizationBrandColorOverride = true
   
   enum Animations {
      static let globalAnimationDuration = 0.25
   }
}

extension CGFloat {
   var aspected: CGFloat {
      self * Config.sizeAspectCoeficient
   }

   var aspectInverted: CGFloat {
      self / Config.sizeAspectCoeficient
   }

   var aspectedByHeight: CGFloat {
      self * Config.heightAspectCoeficient
   }

   var aspectedByHeightInvert: CGFloat {
      self / Config.heightAspectCoeficient
   }
}

extension Int {
   var aspected: CGFloat {
      CGFloat(self) * Config.sizeAspectCoeficient
   }

   var aspectInverted: CGFloat {
      CGFloat(self) / Config.sizeAspectCoeficient
   }

   var aspectedByHeight: CGFloat {
      CGFloat(self) * Config.heightAspectCoeficient
   }

   var aspectedByHeightInvert: CGFloat {
      CGFloat(self) / Config.heightAspectCoeficient
   }
}

extension Config {
   enum AppConfig {
      case debug
      case testFlight
      case production
   }

   private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

   // This can be used to add debug statements.
   static var isDebug: Bool {
      #if DEBUG
         return true
      #else
         return false
      #endif
   }

   static var appConfig: AppConfig {
      if isDebug {
         return .debug
      } else if isTestFlight {
         return .testFlight
      } else {
         return .production
      }
   }
}

extension Config {
   static var privacyPolicyPayload: (title: String, pdfName: String) {
      (title: "Политика конфиденциальности", pdfName: "privacyPolicy")
   }

   static var userAgreementPayload: (title: String, pdfName: String) {
      (title: "Пользовательское соглашение", pdfName: "user_agreement")
   }
}

//extension Config {
//   static let vkAppId = "51726748" // "51740206"
//   static let vkSecret = "6Ebd83Yb9rQY9A8fMssI" // "kbC6OILwg2rimuRaNjZr"
//}
