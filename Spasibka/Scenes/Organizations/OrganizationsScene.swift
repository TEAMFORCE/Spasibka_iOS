//
//  OrganizationsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.06.2023.
//

import Foundation
import StackNinja

final class OrganizationsScene<Asset: ASP>: BaseSceneExtended<OrganizationsModel<Asset>> {
   private lazy var organizationsList = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         OrganizationCell<Design>.presenter,
         SpacerPresenter.presenter
      )
      .setNeedsLayoutWhenContentChanged()

   private lazy var createOrganizationButton = ButtonModel()
      .set(Design.state.button.default)
      .title(Design.text.createCommunity)

   private lazy var bottomPopupPresenter = BottomPopupPresenter()

   private lazy var activityIndicator = Design.model.common.activityIndicator
   private lazy var sharePopup = ShareCommunityPopup<Design>()
   private lazy var changeOrganizationPopup = DialogPopupVM<Design>()

   private lazy var darkLoader = DarkLoaderVM<Design>()
   private lazy var systemErrorPopup = Design.model.common.systemErrorPopup
      .on(\.didClosed, self) {
         $0.centerPopupPresenter.setState(.hide)
      }

   private lazy var centerPopupPresenter = CenterPopupPresenter()

   private lazy var createOrganizationFinishWork = Out<CommunityParams>()
      .onSuccess { [weak self] in
         self?.setState(.darkLoading)
         self?.scenario.events.createOrganization.sendAsyncEvent($0)
      }
      .onFail { [weak self] in
         self?.setState(.hideDarkLoading)
      }

   override func start() {
      super.start()

      title(Design.text.organizations)

      mainVM.bodyStack
         .padHorizontal(0)
         .padBottom(48)
         .arrangedModels(
            activityIndicator,
            organizationsList,
            Spacer(),
            createOrganizationButton
               .wrappedX()
               .padHorizontal(16)
         )

      initScenario(.init(
         payload: on(\.input),
         reloadOrganizations: .init(),
         didSelectItemAtIndex: organizationsList.on(\.didSelectItemAtIndex),
         changeOrganization: Out<Organization>(),
         didTapCreateOrganization: createOrganizationButton.on(\.didTap),
         createOrganization: .init()
      ))
      scenario.configureAndStart()
   }
}

extension OrganizationsScene: StateMachine {
   func setState(_ state: ModelState) {
      switch state {
      case let .presentOrganizations(organizations):
         activityIndicator.hidden(true)
         organizationsList.items(organizations + [SpacerItem(64)])
      case let .presentInviteLinkPopup(orgName, link):
         sharePopup.setState((orgName: orgName, sharingKey: link))
         sharePopup.closeButtonEvent
            .onSuccess(self) {
               $0.bottomPopupPresenter.setState(.hide)
            }
         bottomPopupPresenter
            .setState(
               .presentWithAutoHeight(model: sharePopup, onView: vcModel?.superview)
            )
      case let .presentChangeOrganizationPopup(organization):
         changeOrganizationPopup.setState(
            .init(
               title: "\(Design.text.changeOrganizationPopupTitle)\n\(organization.name)?",
               subtitle: nil,
               buttonText: Design.text.confirm,
               buttonSecondaryText: Design.text.cancel
            )
         )
         bottomPopupPresenter.setState(.presentWithAutoHeight(
            model: changeOrganizationPopup,
            onView: vcModel?.superview
         ))
         changeOrganizationPopup.didTapButtonWork
            .onSuccess(self) {
               $0.bottomPopupPresenter.setState(.hide)
               $0.scenario.events.changeOrganization.sendAsyncEvent(organization)
            }
         changeOrganizationPopup.didTapCancelButtonWork
            .onSuccess(bottomPopupPresenter) {
               $0.setState(.hide)
            }
      case .presentCreateOrganization:
         let currentDate = Date()
         let futureDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
         let params = CommunityParams(
            name: "",
            startDate: currentDate,
            endDate: futureDate ?? currentDate,
            startBalance: 50,
            headStartBalance: 50
         )
         Asset.router?.route(
            .presentModally(.automatic),
            scene: \.createOrganization,
            payload: params,
            finishWork: createOrganizationFinishWork
         )
      case .finishCreateOrganization:
         setState(.hideDarkLoading)
         bottomPopupPresenter.hideAll(animated: false)
         scenario.events.reloadOrganizations.sendAsyncEvent()
      case .createOrganizationError:
         activityIndicator.hidden(true)
         setState(.hideDarkLoading)
         centerPopupPresenter.hideAll(animated: false)
         bottomPopupPresenter.hideAll(animated: false)
         centerPopupPresenter.setState(.present(model: systemErrorPopup, onView: vcModel?.superview))
      case .darkLoading:
         darkLoader.setState(.loading(onView: vcModel?.superview))
      case .hideDarkLoading:
         darkLoader.setState(.hide)
      }
   }
}
