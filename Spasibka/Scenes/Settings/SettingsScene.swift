//
//  SettingsViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 22.08.2022.
//

import StackNinja
import UIKit

struct SettingsViewEvent: InitProtocol {}

final class SettingsScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   BrandDoubleStackVM<Asset.Design>,
   Asset,
   UserData,
   Void
>, Scenarible {
   lazy var scenario = SettingsScenario<Asset>(
      works: SettingsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: .init(
         payload: on(\.input),
         logout: logoutButton.on(\.didTap),
         routeOrganizations: organizationCell.view.startTapGestureRecognize().on(\.didTap),
         routePrivacy: privacyPolicy.view.startTapGestureRecognize().on(\.didTap),
         routeAgreement: userAgreement.view.startTapGestureRecognize().on(\.didTap),
         routeAbout: about.view.startTapGestureRecognize().on(\.didTap),
         routeFeedback: feedback.view.startTapGestureRecognize().on(\.didTap),
         routeLanguage: language.view.startTapGestureRecognize().on(\.didTap)
      )
   )

   // MARK: - Frame Cells

   private lazy var organizationCell = OrganizationCell<Design>()

   private lazy var shareOrganization = IconTitleX()
      .setAll { icon, title in
         icon
            .image(Design.icon.tablerShare, color: Design.color.iconContrast)
         title
            .textColor(Design.color.text)
            .text(Design.text.inviteMembers)
      }
      .spacing(16)
      .padding(Design.params.cellContentPadding)
      .lefted()
      .hidden(true)

   private lazy var privacyPolicy = IconTitleX()
      .setAll { icon, title in
         icon
            .image(Design.icon.uilShieldSlash, color: Design.color.iconContrast)
         title
            .textColor(Design.color.text)
            .text(Design.text.privacyPolicy)
      }
      .spacing(16)
      .padding(Design.params.cellContentPadding)
      .lefted()

   private lazy var userAgreement = IconTitleX()
      .setAll { icon, title in
         icon
            .image(Design.icon.tablerUsers, color: Design.color.iconContrast)
         title
            .textColor(Design.color.text)
            .text(Design.text.termsOfUse)
      }
      .spacing(16)
      .padding(Design.params.cellContentPadding)
      .lefted()

   private lazy var about = IconTitleX()
      .setAll { icon, title in
         icon
            .image(Design.icon.tablerInfoCircle, color: Design.color.iconContrast)
         title
            .textColor(Design.color.text)
            .text(Design.text.aboutTheApp)
      }
      .spacing(16)
      .padding(Design.params.cellContentPadding)
      .lefted()
   
   private lazy var feedback = IconTitleX()
      .setAll { icon, title in
         icon
            .image(Design.icon.tablerPhone, color: Design.color.iconContrast)
         title
            .textColor(Design.color.text)
            .text(Design.text.feedback)
      }
      .spacing(16)
      .padding(Design.params.cellContentPadding)
      .lefted()
   
   private lazy var language = IconTitleX()
      .setAll { icon, title in
         icon
            .image(Design.icon.tablerWorld, color: Design.color.iconContrast)
         title
            .textColor(Design.color.text)
            .text(Design.text.language)
      }
      .spacing(16)
      .padding(Design.params.cellContentPadding)
      .lefted()

   private lazy var logoutButton = Design.button.default
      .set(Design.state.button.brandSecondary)
      .title(Design.text.logoutButton)

   private lazy var activityIndicator = Design.model.common.activityIndicator
      .height(72)

   private lazy var useCase = Asset.apiUseCase

   override func start() {
      vcModel?
         .title(Design.text.settings)

      configure()
      setState(.initial)
      scenario.configureAndStart()
   }

   func configure() {
      mainVM.bodyStack
         .padHorizontal(0)
         .padBottom(48)
         .arrangedModels([
            organizationCell,
            Spacer(16),
            StackModel()
               .padHorizontal(16)
               .arrangedModels(
                  activityIndicator,
                  shareOrganization,
                  language,
                  privacyPolicy,
                  userAgreement,
                  feedback,
                  about,
                  Spacer(),
                  logoutButton
               ),
         ])
   }
}

enum SettingsState {
   case initial
   case currentOrganization(Organization)
}

extension SettingsScene: StateMachine {
   func setState(_ state: SettingsState) {
      switch state {
      case .initial:
         organizationCell.hidden(true)
      case let .currentOrganization(organization):
         activityIndicator.hidden(true)
         organizationCell.setState(.init(
            iconUrl: organization.photo,
            iconPlaceholder: Design.icon.anonAvatar,
            title: Design.text.currentOrganization,
            body: organization.name,
            buttonIcon: Design.icon.tablerSettings,
            buttonTintColor: Design.color.iconBrand,
            backColor: Design.color.backgroundBrandSecondary
         ))
         organizationCell.hidden(false, isAnimated: true)
      }
   }
}
