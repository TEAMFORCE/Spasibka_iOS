//
//  LoginDecors.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 16.08.2022.
//

import StackNinja

enum LoginSceneState {
   //
   case initial
   case joinToCommunity(userName: String?)
   //
   case nameInputParseSuccess(String)
   case nameInputParseError(String)
   //
   case invalidUserName
   case connectionError
   //
   case startActivityIndicator
   case hideActivityIndicator
   //
   case routeAuth(authResult: AuthResult, userName: String, sharingKey: String?)
   case routeOrganizations([OrganizationAuth])
   case routeNewUser(authResult: AuthNewUserResult, userName: String, sharingKey: String?)
   
   case flag(Bool)
}

// MARK: - View models

final class LoginViewModels<Asset: AssetProtocol>: BaseModel, Assetable {
   //
   lazy var activityIndicator = Design.model.common.activityIndicator
      .hidden(true)
   //
   lazy var userNameInputModel = TopBadger<IconTextField<Design>>()
      .set(.badgeLabelStates(Design.state.label.regular14error))
      .set(.badgeState(.backColor(Design.color.background)))
      .set(.hideBadge)
      .set {
         $0.mainModel.icon
            .image(Design.icon.user)
            .imageTintColor(Design.color.iconBrand)
         $0.mainModel.textField
            .disableAutocorrection()
            .placeholder(Design.text.userName)
            .placeholderColor(Design.color.textFieldPlaceholder)
      }

   lazy var getCodeButton: ButtonModel = Design.button.inactive
      .title(Design.text.getCodeButton)
}
