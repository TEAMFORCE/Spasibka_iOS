//
//  MainWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.08.2022.
//

import Foundation
import StackNinja

final class MainWorksStorage: InitProtocol {
   var currentUser: UserData?
}

protocol MainWorksProtocol {
}

final class MainWorks<Asset: AssetProtocol>: BaseWorks<MainWorksStorage, Asset>, MainWorksProtocol, SaveLoginResultsWorksProtocol {
   internal lazy var apiUseCase = Asset.apiUseCase
   private lazy var userDefaults = Asset.userDefaultsWorks

   var loadProfile: VoidWork { .init { [weak self] work in
      self?.apiUseCase.loadMyProfile
         .doAsync()
         .onSuccess { user in
            guard let self else {
               work.fail()
               return
            }

            let orgId = user.profile.organizationId
            let appLanguage = user.profile.language ?? "ru"
            Self.store.currentUser = user
            self.userDefaults.saveValueWork()
               .doAsync(UserDefaultsData(value: orgId, key: .currentOrganizationID))
               .onFail {
                  work.fail()
               }
               .doInput(UserDefaultsValue.currentUser(user))
               .doNext(self.userDefaults.saveAssociatedValueWork)
               .doInput(UserDefaultsValue.appLanguage(appLanguage))
               .doNext(self.userDefaults.saveAssociatedValueWork)
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
   }.retainBy(retainer) }

   var getProfile: Out<UserData> { .init {
      if let userData = Self.store.currentUser {
         $0.success(userData)
      } else {
         $0.fail()
      }
   }}

   var getNotificationsAmount: Work<Void, Int> { .init { [weak self] work in
      self?.apiUseCase.getNotificationsAmount
         .doAsync()
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getUserData: Out<UserData> { .init { work in
      guard let userData = Self.store.currentUser else { work.fail(); return }

      work.success(userData)
   }}

   var loadBrandSettingsAndConfigureAppIfNeeded: Work<Void, Void> { .init { [weak self] work in
      guard let orgId = Self.store.currentUser?.profile.organizationId else {
         work.success()
         return
      }

      self?.apiUseCase.getOrganizationBrandSettings
         .doAsync(orgId)
         .doNext(BrandSettings.shared.updateSettingsWork)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }

   var checkThatUserDataFilledCorrectly: VoidWork { .init { work in
      guard let userData = Self.store.currentUser else {
         work.fail()
         return
      }
      let firstName = userData.profile.firstName
      let lastName = userData.profile.surName
      let isOk = firstName.unwrap.isNotEmpty && lastName.unwrap.isNotEmpty
      if isOk {
         work.success()
      } else {
         work.fail()
      }
   }.retainBy(retainer) }

}

