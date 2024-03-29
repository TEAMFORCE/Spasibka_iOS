//
//  OrganizationsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.06.2023.
//

import StackNinja

final class OrganizationsScenario<Asset: AssetProtocol>: BaseScenarioExtended<OrganizationsModel<Asset>> {
   override func configure() {
      super.configure()

      events.payload
         .doNext(works.storePayload)
         .doSaveResult()
         .doVoidNext(works.loadInviteLink)
         .doAnyway()
         .doVoidNext(works.getOrganizations)
         .onSuccess(setState) {
            .presentOrganizations($0)
         }

      events.reloadOrganizations
         .doNext(works.loadOrganizations)
         .doSendEvent(events.payload)

      events.didSelectItemAtIndex
         .doNext(works.getOrganizationElseInviteLink)
         .onSuccess(setState) { .presentChangeOrganizationPopup($0) }
         .onFail(setState) { (orgName: String, link: String) in
            .presentInviteLinkPopup(orgName: orgName, link: link)
         }
         .onFail {
            log("no invite link")
         }

      events.changeOrganization
         .doNext(works.changeOrganization)
         .onSuccess {
            Asset.router?.route(
               .push,
               scene: \.verify,
               payload: .existUser(authResult: $0.0, userName: $0.userName, sharedKey: nil)
            )
         }

      events.didTapCreateOrganization
         .onSuccess(setState) { .presentCreateOrganization }

      events.createOrganization
         .doSaveResult()
         .doNext(works.createCommunityWithParams)
         .onSuccessMixSaved(setState) { (response: CommunityResponse, saved: CommunityParams) in
            [
               .finishCreateOrganization,
               .presentInviteLinkPopup(orgName: saved.name.unwrap, link: response.inviteLink.unwrap),
            ]
         }
         .onFail(setState, .createOrganizationError)
   }
}
