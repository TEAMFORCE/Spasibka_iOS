//
//  SettingsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.06.2023.
//

import StackNinja
import UIKit

struct SettingsScenarioEvents: ScenarioEvents {
   let payload: Out<UserData>
   let logout: VoidWork
   let routeOrganizations: VoidWork
   let routePrivacy: VoidWork
   let routeAgreement: VoidWork
   let routeAbout: VoidWork
   let routeFeedback: VoidWork
   let routeLanguage: VoidWork
}

final class SettingsScenario<Asset: AssetProtocol>: BaseWorkableScenario<
SettingsScenarioEvents,
SettingsState,
SettingsWorks<Asset>
> {
   override func configure() {
      super.configure()

      events.payload
         .doNext(works.initial)
         .doNext(works.loadOrganizationsAndGetCurrent)
         .onSuccess(setState) {
            .currentOrganization($0)
         }

      events.routeOrganizations
         .doNext(works.getOrganizations)
         .onSuccess {
            Asset.router?.route(.push, scene: \.organizations, payload: $0)
         }

      events.logout
         .doNext(works.logout)
         .doAnyway()
         .onSuccess {
            Asset.router?.route(.presentInitial, scene: \.digitalThanks, payload: ())
         }

      events.routePrivacy
         .onSuccess {
            Asset.router?.route(
               .push,
               scene: \.pdfViewer,
               payload: Config.privacyPolicyPayload
            )
         }

      events.routeAgreement
         .onSuccess {
            Asset.router?.route(
               .push,
               scene: \.pdfViewer,
               payload: Config.userAgreementPayload
            )
         }

      events.routeAbout
         .onSuccess {
            Asset.router?.route(.push, scene: \.about)
         }
      
      events.routeFeedback
         .onSuccess {
            Asset.router?.route(.push, scene: \.feedback)
         }
      
      events.routeLanguage
         .onSuccess {
            Asset.router?.route(.push, scene: \.language)
         }
   }
}
