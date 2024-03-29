//
//  VerifyWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import Foundation
import StackNinja
import UIKit

protocol VerifyBackstageProtocol: Assetable {}

final class VerifyWorks<Asset: AssetProtocol>: BaseWorks<VerifyWorks.Temp, Asset>, VerifyBackstageProtocol {
   //
   let apiUseCase = Asset.apiUseCase
   private lazy var userDefaults = Asset.userDefaultsWorks

   private lazy var smsParser = SmsCodeCheckerModel()

   // Temp Storage
   final class Temp: InitProtocol {
      var userName: String = "" {
         didSet {
            if userName.isEmpty, let saved = UserDefaults.standard.loadString(forKey: .userPrivacyAppliedForUserName) {
               userName = saved
            }
         }
      }

      var userID: Int?

      var smsCodeInput: String?
      var authResult: AuthResult?
      var newUserAuthResult: AuthNewUserResult?
      var sharedKey: String?

      var isPolicyAgreedAlready = false
      var isPoliceCheckmarked = false
   }

   // MARK: - Works
   
   var loadBrandSettingsAndConfigureAppIfNeeded: Work<Void, Void> { .init { [weak self] work in
      self?.apiUseCase.loadMyProfile
         .doAsync()
         .onSuccess { user in
            guard let orgId = user.profile.organizationId else {
               work.fail(); return
            }
//            let orgId = user.profile.organizationId
            self?.apiUseCase.getOrganizationBrandSettings
               .doAsync(orgId)
               .onFail {
                  work.fail()
               }
               .doNext(BrandSettings.shared.updateSettingsWork)
               .onSuccess {
                  work.success()
               }
               .onFail {
                  work.fail()
               }
         }
         .onFail {
            work.fail()
         }
   } }

   var saveInput: In<VerifySceneInput> { .init { work in
      let input = work.in

      switch input {
      case let .existUser(authResult, userName, sharedKey):
         Self.store.authResult = authResult
         Self.store.userName = userName
         Self.store.sharedKey = sharedKey
      case let .newUser(newUserResult, userName, sharedKey):
         Self.store.newUserAuthResult = newUserResult
         Self.store.userName = userName
         Self.store.sharedKey = sharedKey
      }

      work.success()
   }}

   var loadUserAgreementsApplied: Work<Void, Void> { .init { [weak self] work in
      self?.userDefaults.loadValueWork()
         .doAsync(.userPrivacyAppliedForUserName)
         .onSuccess {
            if $0 == Self.store.userName {
               Self.store.isPolicyAgreedAlready = true
               Self.store.isPoliceCheckmarked = true
               work.success()
            } else {
               Self.store.isPoliceCheckmarked = false
               work.fail()
            }
         }
         .onFail {
            Self.store.isPoliceCheckmarked = false
            work.fail()
         }
   } }

   var checkThatUserAgreementsAppliedNow: Work<Void, Void> { .init { work in
      if Self.store.isPoliceCheckmarked {
         work.success()
      } else {
         work.fail()
      }
   } }

   var checkThatUserAgreementsAppliedLongTimeAgo: Work<Void, Void> { .init { work in
      if Self.store.isPolicyAgreedAlready {
         work.success()
      } else {
         work.fail()
      }
   } }

   var verifyCode: Out<VerifyResultBody> { .init { [weak self] work in
      guard
         let inputCode = Self.store.smsCodeInput
      else {
         work.fail()
         return
      }

      if Self.store.authResult != nil {
         self?.verifyCodeForExistingUser
            .doAsync()
            .onSuccess {
               work.success($0)
            }
            .onFail {
               work.fail()
            }
      } else if Self.store.newUserAuthResult != nil {
         self?.verifyCodeForNewUser
            .doAsync()
            .onSuccess {
               work.success($0)
            }
            .onFail {
               work.fail()
            }
      } else {
         work.fail()
      }
   }}

   private var verifyCodeForExistingUser: Out<VerifyResultBody> { .init { [weak self] work in
      guard
         let inputCode = Self.store.smsCodeInput,
         let authResult = Self.store.authResult
      else {
         work.fail()
         return
      }

      let request = VerifyRequest(
         smsCode: inputCode,
         xId: authResult.xId,
         xCode: authResult.xCode,
         organizationId: authResult.organizationId,
         sharingKey: Self.store.sharedKey
      )
      let isNumber = authResult.organizationId?.isNumber ?? true

      if isNumber == true {
         self?.apiUseCase.verifyCode
            .doAsync(request)
            .onSuccess {
               let input = UserDefaultsData(value: Self.store.userName, key: .userPrivacyAppliedForUserName)
               self?.userDefaults.saveValueWork()
                  .retainBy(self?.retainer)
                  .doAsync(input)
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      } else {
         self?.apiUseCase.changeOrgVerifyCode
            .doAsync(request)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
   }.retainBy(retainer) }

   private var verifyCodeForNewUser: Out<VerifyResultBody> { .init { [weak self] work in
      guard
         let inputCode = Self.store.smsCodeInput,
         let authResult = Self.store.newUserAuthResult
      else {
         work.fail()
         return
      }

      let request = VerifyRequest(
         smsCode: inputCode,
         xCode: authResult.xCode,
         xEmail: authResult.xEmail,
         xTelegram: authResult.xTelegram,
         sharingKey: Self.store.sharedKey
      )

      self?.apiUseCase.verifyCode
         .doAsync(request)
         .onSuccess {
            let input = UserDefaultsData(value: Self.store.userName, key: .userPrivacyAppliedForUserName)
            self?.userDefaults.saveValueWork()
               .doAsync(input)
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var smsCodeInputParse: Work<String, String> { .init { [weak self] work in
      self?.smsParser.work
         .retainBy(self?.retainer)
         .doAsync(work.input)
         .onSuccess {
            Self.store.smsCodeInput = $0
            work.success(result: $0)
         }
         .onFail { (text: String) in
            Self.store.smsCodeInput = nil
            work.fail(text)
         }
   }}

   var chackThatInputParseOk: Work<Void, Void> { .init { work in
      if Self.store.smsCodeInput != nil && Self.store.isPoliceCheckmarked || Self.store.isPolicyAgreedAlready {
         work.success()
      } else {
         work.fail()
      }
   }}

   var updatePolicyCheckMark: MapIn<Bool> { .init {
      Self.store.isPoliceCheckmarked = $0
   }}

   var getUserName: MapOut<String> { .init {
      Self.store.userName
   }}
}

extension VerifyWorks: SaveLoginResultsWorksProtocol {}
