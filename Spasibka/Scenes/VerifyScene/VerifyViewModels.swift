//
//  VerifyViewModels.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import StackNinja
import Foundation

enum VerifySceneState {
   //
   case inputSmsCode
   case updateInputField(String)
   
   case setModeWithoutButton
   //
   case automaticallyLogin(String)
   case awaitLoginButton(String)
   case smsInputParseError(String)
   //
   case invalidSmsCode
   case setFcmTokenFailed
   //
   case startActivityIndicator
   
   case enableLoginButton
   case disableLoginButton
   
   case setAgreementCheckmark(Bool)
  
   case presentPrivacyPolicy
   case presentUserAgreement
}

// MARK: - View models

final class VerifyViewModels<Asset: AssetProtocol>: BaseModel, Assetable {
   //
   
   lazy var activityIndicator = Design.model.common.activityIndicator
      .hidden(true)
   //

   lazy var smsCodeInputModel = TopBadger<IconTextField<Design>>()
      .set(.badgeLabelStates(Design.state.label.regular14error))
      .set(.badgeState(.backColor(Design.color.background)))
      .set(.hideBadge)
      .set {
         $0.mainModel.icon
            .image(Design.icon.lock)
            .imageTintColor(Design.color.iconBrand)
         $0.mainModel.textField
            .disableAutocorrection()
            .placeholder(Design.text.enterSmsCode)
            .placeholderColor(Design.color.textFieldPlaceholder)
            .keyboardType(.numberPad)
      }
   
   lazy var userAgreementVM = Stack<CheckMarkModel<Design>>.R<LabelModel>.Ninja()
      .setAll { checkMark, label in
         
         label
            .numberOfLines(0)
            .set(Design.state.label.regular12)
            .textColor(Design.color.iconBrand)
         
         let infoText: NSMutableAttributedString = .init(string: "")
         let text = Design.text.agreementText
         let textPolicy = Design.text.agreementPolicy
         let textAgree = Design.text.agreementTermsOfUse
         
         infoText.append(Design.text.agreeWith.colored(Design.color.text))
         infoText.append(textPolicy.colored(Design.color.textBrand))
         infoText.append(Design.text.andConditions.colored(Design.color.text))
         infoText.append(textAgree.colored(Design.color.textBrand))
         
         label.attributedText(infoText)
         label.view.sizeToFit()
         label.view.makePartsClickable(substring1: textPolicy, substring2: textAgree)
      }
      .spacing(10)
      .alignment(.top)

   lazy var loginButton: ButtonModel = .init(Design.state.button.inactive)
      .title(Design.text.enterButton)

   lazy var systemErrorBlock = Design.model.common.systemErrorBlock
      .hidden(true)
}

extension VerifyViewModels: StateMachine {
   func setState(_ state: VerifySceneState) {
      switch state {
      case .inputSmsCode:
         smsCodeInputModel.hidden(false)
         // loginButton.hidden(false)
         activityIndicator.hidden(true)
         
      case .updateInputField(let value):
         smsCodeInputModel.mainModel.textField.set(.text(value))
         
      case .setModeWithoutButton:
         loginButton.hidden(true)
         userAgreementVM.hidden(true)

      case .automaticallyLogin(let value):
         smsCodeInputModel.mainModel.textField.set(.text(value))
         loginButton.set(Design.state.button.default)
         loginButton.send(\.didTap)
         activityIndicator.hidden(true)
         
      case .awaitLoginButton(let value):
         smsCodeInputModel.mainModel.textField.set(.text(value))
         loginButton.set(Design.state.button.default)
         activityIndicator.hidden(true)

      case .smsInputParseError(let value):
         smsCodeInputModel.mainModel.textField.set(.text(value))
         loginButton.set(Design.state.button.inactive)
         activityIndicator.hidden(true)

      case .invalidSmsCode:
         smsCodeInputModel.set(.presentBadge(" " + Design.text.wrongCode + " "))
         activityIndicator.hidden(true)
      case .setFcmTokenFailed:
         systemErrorBlock.hidden(false)
      case .startActivityIndicator:
         systemErrorBlock.hidden(true)
         activityIndicator.hidden(false)
      case .enableLoginButton:
         systemErrorBlock.hidden(true)
         loginButton.set(Design.state.button.default)
      case .disableLoginButton:
         loginButton.set(Design.state.button.inactive)
      case .setAgreementCheckmark(let value):
            userAgreementVM.models.main.setState(value)
      case .presentPrivacyPolicy:
         Asset.router?.route(.push, scene: \.pdfViewer, payload: Config.privacyPolicyPayload)
      case .presentUserAgreement:
         Asset.router?.route(.push, scene: \.pdfViewer, payload: Config.userAgreementPayload)
      }
   }
}
