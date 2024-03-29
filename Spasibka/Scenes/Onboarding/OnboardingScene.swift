//
//  OnboardingScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import StackNinja
import UIKit

final class OnboardingScene<Asset: ASP>: BaseSceneExtended<Onboarding<Asset>> {
   private lazy var stepLabel = Design.label.medium16
   private lazy var pagingModel = PagingScrollViewModel()

   // pages
   private lazy var pageCreateCommunity = OnboardPageVM<Design>()
      .setStates(.initialValues(
         image: Design.icon.smartPeopleIllustrate,
         buttonText: Design.text.createCommunity
      ))

   private lazy var pageJoinToCommunity = OnboardPageVM<Design>()
      .setStates(.initialValues(
         image: Design.icon.challengeWinnerIllustrateMedium,
         buttonText: Design.text.connectToCommunity
      ))

   private lazy var descriptionBlock = TitleBodyY()
      .setAll {
         $0
            .set(Design.state.label.medium20)
            .alignment(.center)
         $1
            .set(Design.state.label.medium14)
            .textColor(Design.color.textSecondary)
            .lineSpacing(8)
            .alignment(.center)
      }
      .spacing(8)

   // popups
   private lazy var createCommunityPopup = OnboardPopupVM<Design>()
      .setStates(
         .initial(
            title: Design.text.createCommunity,
            subtitle: Design.text.fillCommunityInformation,
            inputPlaceholder: Design.text.title
         ),
         .continueButtonEnabled(false)
      )

   private lazy var joinCommunityPopup = OnboardPopupVM<Design>()
      .setStates(
         .initial(
            title: Design.text.connectToCommunity,
            subtitle: Design.text.invitationCode,
            inputPlaceholder: Design.text.code
         ),
         .continueButtonEnabled(false)
      )

   private lazy var bottomPopupPresenter = BottomPopupPresenter()
   private lazy var centerPopupPresenter = CenterPopupPresenter()

   private lazy var loadingScreen = DarkLoaderVM<Design>()

   override func start() {
      super.start()

      initScenario(.init(
         input: on(\.input),
         //
         didTapCreateCommunity: pageCreateCommunity.buttonModel.on(\.didTap),
         didTapJoinCommunity: pageJoinToCommunity.buttonModel.on(\.didTap),
         //
         didEditingCreateCommunityTitle: createCommunityPopup.inputField.on(\.didEditingChanged),
         didEditingJoinCommunitySharedKey: joinCommunityPopup.inputField.on(\.didEditingChanged),
         //
         didTapContinueCreateCommunity: createCommunityPopup.continueButton.on(\.didTap),
         didTapContinueJoinCommunity: joinCommunityPopup.continueButton.on(\.didTap),
         //
         didTapCancelPopups: .init()
      ))

      vcModel?.title(Design.text.onboardingTitle)
      mainVM.backColor(Design.color.background)

      mainVM.bodyStack
         .padding(.horizontalOffset(0))
         .padBottom(16)
         .safeAreaOffsetDisabled()
         .arrangedModels(
            Spacer(24),
            stepLabel.centeredX(),
            Spacer(8),
            pagingModel,
            pagingModel.pageControlModel
               .pageIndicatorTintColor(Design.color.iconBrandSecondary)
               .currentPageIndicatorTintColor(Design.color.iconBrand),
            Spacer(32),
            descriptionBlock.centeredX(),
            Spacer(32)
         )

      vcModel?.on(\.viewDidFirstAppear, self) {
         $0.setState(.initial)
      }

      scenario.configureAndStart()
   }
}

extension OnboardingScene: StateMachine {
   func setState(_ state: ModelState) {
      switch state {
      case .initial:
         stepLabel.text(Design.text.step + " 1/2")
         pagingModel.setState(.setViewModels([
            pageCreateCommunity,
            pageJoinToCommunity,
         ]))
         descriptionBlock.title.text(Design.text.communities)
         descriptionBlock.body.text(Design.text.createCommunityDescription)
      case let .createCommunityPopupState(enabled, text):
         createCommunityPopup.setStates(
            .continueButtonEnabled(enabled),
            .textFieldText(text)
         )
      case let .joinCommunityPopupState(enabled, text):
         joinCommunityPopup.setStates(
            .continueButtonEnabled(enabled),
            .textFieldText(text)
         )
      case .presentCreateCommunityPopup:
         bottomPopupPresenter.setState(
            .presentWithAutoHeight(model: createCommunityPopup, onView: vcModel?.superview)
         )
         createCommunityPopup.cancelButton.on(\.didTap, self) {
            $0.scenario.events.didTapCancelPopups.sendAsyncEvent()
         }
      case .presentJoinCommunityPopup:
         bottomPopupPresenter.setState(
            .presentWithAutoHeight(model: joinCommunityPopup, onView: vcModel?.superview)
         )
         joinCommunityPopup.cancelButton.on(\.didTap, self) {
            $0.scenario.events.didTapCancelPopups.sendAsyncEvent()
         }
      case .hidePopups:
         bottomPopupPresenter.setState(.hide)
      case let .routeToConfigureCommunityWithName(communityName):
         bottomPopupPresenter.setState(.hide)
         Asset.router?.route(.push, scene: \.onboarding2, payload: communityName)
      case .loading:
         loadingScreen.setState(.loading(onView: vcModel?.superview))
      case .loadingSuccess:
         loadingScreen.setState(.hide)
      case .loadingError:
         loadingScreen.setState(.hide)
         centerPopupPresenter.setState(
            .presentWithAutoHeight(
               model: Design.model.common.systemErrorPopup
                  .on(\.didClosed, { [weak self] in
                     self?.centerPopupPresenter.setState(.hide)
                  }),
               onView: vcModel?.superview
            )
         )
      }
   }
}
