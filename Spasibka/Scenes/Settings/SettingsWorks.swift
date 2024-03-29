//
//  SettingsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.06.2023.
//

import StackNinja
import UIKit

final class SettingsStore: InitProtocol {
   var userData: UserData?
   var organizations: [Organization]?
}

final class SettingsWorks<Asset: ASP>: BaseWorks<SettingsStore, Asset> {

   let apiUseCase = Asset.apiUseCase

   var initial: In<UserData> { .init {
      Self.store.userData = $0.in
      $0.success()
   }}

   var loadOrganizationsAndGetCurrent: Out<Organization> { .init { [weak self] work in

      self?.loadOrganizations
         .retainBy(self?.retainer)
         .doAsync()
         .onSuccess {
            Self.store.organizations = $0
            if let current = $0.first(where: { $0.isCurrent }) {
               work.success(current)
            } else {
               work.fail()
            }
         }
         .onFail {
            work.fail()
         }
   }}

   var getOrganizations: Out<[Organization]> { .init { work in
      if let organizations = Self.store.organizations {
         work.success(organizations)
      } else {
         work.fail()
      }
   } }

   var logout: VoidWork { .init { [weak self] work in
      guard let self else { work.fail(); return }
      
      UserDefaults.standard.setIsLoggedIn(value: false)
      UserDefaults.standard.clearForKey(.userPrivacyAppliedForUserName)
      UserDefaults.standard.clearForKey(.currentOrganizationID)
      self.apiUseCase.safeStringStorage.applyState(.clearForKey(Config.vkAccessTokenKey))

      guard
         let userId = Self.store.userData?.profile.id,
         let deviceId = UIDevice.current.identifierForVendor?.uuidString
      else { work.fail(); return }
      
      let request = RemoveFcmToken(device: deviceId, userId: userId)

      self.apiUseCase.logout
         .doAsync()
         .doInput(request)
         .doNext(self.apiUseCase.removeFcmToken)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   }}
}

extension SettingsWorks: OrganizationsWorksProtocol {}
