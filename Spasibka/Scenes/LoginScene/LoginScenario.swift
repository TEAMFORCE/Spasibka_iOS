//
//  LoginScenery.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 16.08.2022.
//

import StackNinja

//typealias Eventee<T> = Work<Void, T>

typealias VoidWork = Work<Void, Void>

struct LoginScenarioEvents: ScenarioEvents {
   let input: Out<LoginInput>
   let userNameStringEvent: Out<String>
   let getCodeButtonEvent: Out<Void>
}

final class LoginScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<
      LoginScenarioEvents,
      LoginSceneState,
      LoginWorks<Asset>
   >
{
   override func configure() {
      super.configure()
      start
         .doNext(works.getFlag)
         .onSuccess(setState) { .flag($0) }
      
      events.input
         .doNext(works.saveSceneInput)
         .onSuccess(setState) { .joinToCommunity(userName: $0) }
      
      // setup input field reactions
      events.userNameStringEvent
         .doNext(works.inputTextCacher)
         .doNext(works.loginNameInputParse)
         .onSuccess(setState) { .nameInputParseSuccess($0) }
         .onFail(setState) { .nameInputParseError($0) }

      // setup get code button reaction
      events.getCodeButtonEvent
         .onSuccess(setState, .startActivityIndicator)
         .doNext(works.authByName)
         .onSuccess(setState) {
            switch $0.authResult {
            case .auth(let value):
               return .routeAuth(authResult: value, userName: $0.userName, sharingKey: $0.sharingKey)
            case .existUser(let value):
               return .routeOrganizations(value)
            case .newUser(let value):
               return .routeNewUser(authResult: value, userName: $0.userName, sharingKey: $0.sharingKey)
            }
         }
         .onFail(setState) { (error: ApiEngineError) in
            if case .unknown = error {
               return .connectionError
            } else {
               return .invalidUserName
            }
         }
   }
}
