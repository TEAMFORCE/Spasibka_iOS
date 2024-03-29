//
//  VerifyScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import StackNinja

// MARK: - VerifyScene

enum VerifySceneInput {
   case existUser(authResult: AuthResult, userName: String, sharedKey: String?)
   case newUser(authResult: AuthNewUserResult, userName: String, sharedKey: String?)
}

final class VerifyScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   DoubleStackHeaderBrandLogoVM<Asset.Design>,
   Asset,
   VerifySceneInput,
   Void
>, Scenarible {
   //

   private lazy var viewModels = VerifyViewModels<Asset>()

   lazy var scenario = VerifyScenario(
      works: VerifyWorks<Asset>(),
      stateDelegate: viewModels.stateDelegate,
      events: VerifyScenarioEvents(
         saveInput: on(\.input),
         smsCodeStringEvent: viewModels.smsCodeInputModel.mainModel.textField.on(\.didEditingChanged),
         loginButtonEvent: viewModels.loginButton.on(\.didTap),
         policyCheckmarkSelected: viewModels.userAgreementVM.models.main.on(\.didSelected),
         didTapAgreementIndex: viewModels.userAgreementVM.models.right.view.on(\.didSelectRangeIndex)
      )
   )

   // MARK: - Start

   override func start() {
      configure()

      viewModels.setState(.inputSmsCode)
      scenario.configureAndStart()
   }
}

// MARK: - Configure presenting

private extension VerifyScene {
   func configure() {
      mainVM.header
         .text(Design.text.autorisation)
      mainVM.bodyStack
         .arrangedModels([
            viewModels.smsCodeInputModel,
            Spacer(Design.params.buttonsSpacingY),
//            viewModels.userAgreementVM,
            Spacer(Design.params.buttonsSpacingY),
            viewModels.loginButton,
            viewModels.activityIndicator,
            viewModels.systemErrorBlock,
            Grid.xxx.spacer
         ])
   }
}
