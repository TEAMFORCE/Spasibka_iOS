//
//  LoginScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.06.2022.
//

import Foundation
import StackNinja

// MARK: - LoginScene

struct LoginInput {
   let sharedKey: String
   let userName: String?
}

final class LoginScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   DoubleStackHeaderBrandLogoVM<Asset.Design>,
   Asset,
   LoginInput,
   Void
>, Scenarible {
   //

   private lazy var viewModels = LoginViewModels<Asset>()
   private lazy var vkButton = VKLoginButton<Design>()
      .hidden(true)
      .on(\.didTap, self) {
         if let sharedKey = $0.inputValue?.sharedKey {
            Asset.router?.route(.push, scene: \.loginVK, payload: .deeplink(sharedKey: sharedKey))
         } else {
            Asset.router?.route(.push, scene: \.loginVK, payload: .normal)
         }
      }
   
   private let orLabel = LabelModel()
      .set(Design.state.label.regular14)
      .textColor(Design.color.textSecondary)
      .alignment(.center)
      .numberOfLines(0)
      .text(Design.text.or)
      .hidden(true)

   private lazy var centerPopupPresenter = CenterPopupPresenter()

   lazy var scenario = LoginScenario(
      works: LoginWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: LoginScenarioEvents(
         input: on(\.input),
         userNameStringEvent: viewModels.userNameInputModel.mainModel.textField.on(\.didEditingChanged),
         getCodeButtonEvent: viewModels.getCodeButton.on(\.didTap)
      )
   )

   // MARK: - Start

   override func start() {
      configure()
   }
}

// MARK: - Configure presenting

private extension LoginScene {
   func configure() {
      vcModel?.clearBackButton()

      mainVM.bodyStack
         .arrangedModels(
            viewModels.userNameInputModel,
            Spacer(Design.params.buttonsSpacingY),
            LabelModel()
               .set(Design.state.label.regular14)
               .textColor(Design.color.textSecondary)
               .alignment(.center)
               .numberOfLines(0)
               .text(Design.text.userNameDescription),
            Spacer(Design.params.buttonsSpacingY),
            viewModels.getCodeButton,
            viewModels.activityIndicator,
            Spacer(Design.params.buttonsSpacingY),
            orLabel,
            Spacer(Design.params.buttonsSpacingY),
            vkButton,
            Grid.xxx.spacer
         )

      scenario.configureAndStart()
      setState(.initial)
   }
}

extension LoginScene: StateMachine {
   func setState(_ state: LoginSceneState) {
      switch state {
      case .initial:
         mainVM.header.text(Design.text.autorisation)
         viewModels.userNameInputModel.hidden(false)
         viewModels.getCodeButton.hidden(false)
         viewModels.activityIndicator.hidden(true)
      case let .joinToCommunity(userName):
         mainVM.header
            .text(Design.text.connectToCommunity)
            .numberOfLines(2)
         if let userName {
            viewModels.userNameInputModel.mainModel.textField
               .text(userName)
               .userInterractionEnabled(false)
               .textColor(Design.color.textSecondary)
            scenario.events.getCodeButtonEvent.sendAsyncEvent()
         }
      case let .nameInputParseSuccess(value):
         viewModels.userNameInputModel.mainModel.textField.text(value)
         viewModels.getCodeButton.set(Design.state.button.default)
         viewModels.userNameInputModel.set(.hideBadge)
         viewModels.activityIndicator.hidden(true)
      case let .nameInputParseError(value):
         viewModels.userNameInputModel.mainModel.textField.text(value)
         viewModels.getCodeButton.set(Design.state.button.inactive)
         viewModels.userNameInputModel.set(.hideBadge)
         viewModels.activityIndicator.hidden(true)
      case .invalidUserName:
         viewModels.userNameInputModel.set(.presentBadge(" " + Design.text.wrongUsername + " "))
         viewModels.activityIndicator.hidden(true)
         viewModels.getCodeButton.set(Design.state.button.default)
      case .startActivityIndicator:
         viewModels.getCodeButton.set(Design.state.button.inactive)
         viewModels.activityIndicator.hidden(false)
      case .hideActivityIndicator:
         viewModels.activityIndicator.hidden(true)
         viewModels.getCodeButton.set(Design.state.button.default)
      case let .routeAuth(authResult, userName, sharingKey):
         Asset.router?.route(.push, scene: \.verify, payload: .existUser(authResult: authResult, userName: userName, sharedKey: sharingKey))
         setState(.hideActivityIndicator)
      case let .routeOrganizations(value):
         Asset.router?.route(.push, scene: \.chooseOrgScene, payload: .organizations(value))
         setState(.hideActivityIndicator)
      case let .routeNewUser(authResult, userName, sharingKey):
         Asset.router?.route(
            .push,
            scene: \.verify,
            payload: .newUser(
               authResult: authResult,
               userName: userName,
               sharedKey: sharingKey
            )
         )
         setState(.hideActivityIndicator)
      case .connectionError:
         setState(.hideActivityIndicator)
         centerPopupPresenter.setState(
            .presentWithAutoHeight(
               model: Design.model.common.systemErrorPopup
                  .on(\.didClosed) { [weak self] in
                     self?.centerPopupPresenter.setState(.hide)
                  },
               onView: vcModel?.superview
            )
         )
      case .flag(let value):
         vkButton.hidden(value)
         orLabel.hidden(value)
      }
   }
}
