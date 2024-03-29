//
//  OrganizationsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.06.2023.
//

import Foundation
import StackNinja

final class OrganizationsStore: InitClassProtocol {
   var organizations = [Organization]()
   var inviteLink: String?
}

final class OrganizationsWorks<Asset: ASP>: BaseWorks<OrganizationsStore, Asset> {
   let apiUseCase = Asset.apiUseCase
   private let saveLoginResultsWorks = SaveLoginResultsWorks<Asset>()

   var storePayload: In<[Organization]>.Out<[Organization]> { .init { work in
      Self.store.organizations = work.in.sorted { $0.isCurrent && !$1.isCurrent }
      work.success(Self.store.organizations)
   }}

   var getOrganizations: Out<[Organization]> { .init { work in
      work.success(Self.store.organizations.map {
         var value = $0
         value.hasLink = value.isCurrent && Self.store.inviteLink != nil
         return value
      })
   } }

   var getOrganizationElseInviteLink: In<Int>.Out<Organization> { .init { work in
      let org = Self.store.organizations[work.in]
      if org.isCurrent {
         if let link = Self.store.inviteLink {
            work.fail((orgName: org.name, link: link))
         } else {
            work.fail()
            log("No invite link")
         }
      } else {
         work.success(org)
      }
   }}

   var changeOrganization: In<Organization>.Out<(AuthResult, userName: String)> { .init { [weak self] work in
      guard let self else { work.fail(); return }

      let id = work.in.id
      self.apiUseCase.getAutMethod
         .doAsync()
         .doCheck {
            $0 == .vk
         }
         .onSuccess { [weak self] in
            guard let self else { work.fail(); return }

            self.apiUseCase.changeOrganizationViaVK
               .doAsync(id)
               .onFail {
                  work.fail()
               }
               .doMap {
                  (token: $0.token, sessionId: $0.sessionId)
               }
               .doNext(self.saveLoginResultsWorks.saveLoginResults)
               .onSuccess {
                  Asset.router?.route(.presentInitial, scene: \.mainMenu)
                  Asset.router?.route(.presentInitial, scene: \.tabBar)
               }
               .onFail {
                  work.fail()
               }
         }
         .onFail { [weak self] in
            self?.apiUseCase
               .changeOrganization
               .doAsync(id)
               .onSuccess {
                  let authResult = AuthResult(
                     xId: $0.xId,
                     xCode: $0.xCode,
                     account: $0.account,
                     organizationId: $0.organizationId
                  )

                  let userName = UserDefaults.standard.loadValue(forKey: .userPrivacyAppliedForUserName) ?? ""

                  work.success((authResult, userName: userName))
               }
               .onFail {
                  work.fail()
               }
         }
   }}

   var loadInviteLink: VoidWork { .init { [weak self] work in
      self?.apiUseCase.getInviteLink
         .doAsync()
         .onSuccess {
            Self.store.inviteLink = $0.inviteLink
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getInviteLink: Out<String> { .init {
      if let link = Self.store.inviteLink {
         $0.success(link)
      } else {
         $0.fail()
      }
   }}
}

extension OrganizationsWorks: CreateCommunityWorksProtocol {}
extension OrganizationsWorks: UpdateOrganizationParamsProtocol {}
extension OrganizationsWorks: OrganizationsWorksProtocol {}
