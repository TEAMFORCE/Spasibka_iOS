//
//  OrganizationsModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.06.2023.
//

import StackNinja

enum OrganizationsModel<Asset: ASP>: ScenaribleSceneParams {
   typealias Scenery = OrganizationsScenario<Asset>
   typealias ScenarioWorks = OrganizationsWorks<Asset>

   struct ScenarioInputEvents: ScenarioEvents {
      let payload: Out<[Organization]>
      let reloadOrganizations: VoidWork

      let didSelectItemAtIndex: Out<Int>
      let changeOrganization: Out<Organization>
      let didTapCreateOrganization: VoidWork

      let createOrganization: Out<CommunityParams>
   }

   enum ScenarioModelState {
      case presentOrganizations([Organization])
      case presentChangeOrganizationPopup(Organization)
      case presentInviteLinkPopup(orgName: String, link: String)
      case presentCreateOrganization
      case finishCreateOrganization
      case createOrganizationError
      case darkLoading
      case hideDarkLoading
   }

   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = BrandDoubleStackVM<Asset.Design>
   }

   struct InOut: InOutParams {
      typealias Input = [Organization]
      typealias Output = Void
   }
}
