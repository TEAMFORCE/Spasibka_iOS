//
//  VerifyScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import StackNinja

struct VerifyScenarioEvents: ScenarioEvents {   
   let saveInput: Out<VerifySceneInput>
   let smsCodeStringEvent: Out<String>
   let loginButtonEvent: Out<Void>
   
   let policyCheckmarkSelected: Out<Bool>
   let didTapAgreementIndex: Out<Int>
}

final class VerifyScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<
      VerifyScenarioEvents,
      VerifySceneState,
      VerifyWorks<Asset>
   >
{
   override func configure() {
      super.configure()
      
      events.saveInput
         .doNext(works.saveInput)
         .onSuccess(setState, .setModeWithoutButton )
      
      // setup input field reactions
      events.smsCodeStringEvent
         .doNext(works.smsCodeInputParse)
         .onFail(setState) { .smsInputParseError($0) }
         .onSuccess(setState) { [.automaticallyLogin($0), .awaitLoginButton($0)] }
         .onFail(setState) { .smsInputParseError($0) }


      // setup login button reactions
      events.loginButtonEvent
         .onSuccess(setState, .startActivityIndicator)
         //
         .doNext(works.verifyCode)
         .onFail(setState, .invalidSmsCode)
         .doMap {
            (token: $0.token, sessionId: $0.sessionId)
         }
         .doNext(works.saveLoginResults)
         .doNext(works.setFcmToken)
         .onFail(setState, .setFcmTokenFailed)
//         .onSuccess {
//            Asset.router?.route(.presentInitial, scene: \.mainMenu/*, payload: .normal*/)
//            Asset.router?.route(.presentInitial, scene: \.tabBar)
//         }
         .doNext(works.loadBrandSettingsAndConfigureAppIfNeeded)
         .onSuccess {
            Asset.router?.route(.presentInitial, scene: \.mainMenu/*, payload: .normal*/)
            Asset.router?.route(.presentInitial, scene: \.tabBar)
         }
         .onFail {
            print("fail")
         }
         .doVoidRecover(works.getUserName)
         .onSuccess {
            Asset.router?.route(.presentInitial, scene: \.onboarding, payload: $0)
         }
         .onFail {
            print("fail")
         }
   }
}
