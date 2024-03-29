//
//  LoginVKScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 31.08.2023.
//

import StackNinja
import WebKit

enum LoginVKSceneInput {
   case normal
   case deeplink(sharedKey: String)
   case connectToCurrentAccount
   case changeOrganization(id: Int)
}

final class LoginVKScene<Asset: ASP>: BaseSceneModel<
   DefaultVCModel,
   WebViewModel,
   Asset,
   LoginVKSceneInput,
   Void
> {
   private lazy var popupPresenter = CenterPopupPresenter()
   private lazy var bottomPopupPresenter = BottomPopupPresenter()

   private let apiUseCase = Asset.apiUseCase
   private let userDefaultsWorks = Asset.userDefaultsWorks
   private let saveLoginResultsWorks = SaveLoginResultsWorks<Asset>()

   override func start() {
      vcModel?
         .backColor(Design.color.backgroundBrand)
         .navBarBackColor(Design.color.backgroundBrand)
         .navBarTranslucent(true)
         .title("VK ID")
      mainVM
         .scrollBackColor(Design.color.transparent)
         .backColor(Design.color.transparent)
         .on(\.didFinishNavigation, self) { slf, tuple in
            let currentUrlString = tuple.currentURLString
            if currentUrlString.contains("#code") {
               let data = currentUrlString.components(separatedBy: CharacterSet(charactersIn: "=&"))
               guard let code = data[safe: 1] else {
                  slf.presentErrorPopup()
                  return
               }

               slf.getToken(code: code)
            }
         }

      getCode()
   }

   private func getCode() {
      let redirectUri = "https://oauth.vk.com/blank.html"
      let urlString = "https://oauth.vk.com/authorize?client_id=\(SecretConfig.vkAppId)&display=page&redirect_uri=\(redirectUri)&response_type=code&v=5.131"

      guard let url = URL(string: urlString) else { return }

      mainVM.url(url)
   }

   private func getToken(code: String) {
      mainVM.hidden(true)

      
      switch inputValue {
      case let .deeplink(key):
         loginViaVK(code: code, sharedKey: key)
      case .connectToCurrentAccount:
         connectVKAccount(vkCode: code)
         return
      case .normal, .none:
         loginViaVK(code: code, sharedKey: nil)
      case .changeOrganization(let id):
         break
//         changeOrgScene(code: code, orgId: id)
      }
   }
   
//   private func changeOrgScene(code: String, orgId: Int) {
//      var accessToken = ""
//      apiUseCase.vkGetAccessToken
//         .doAsync(code)
//         .onFail(self) {
//            $0.presentErrorPopup()
//         }
//         .onSuccess { [weak self] in
//            self?.apiUseCase.safeStringStorage.applyState(.save((value: $0.accessToken, Config.vkAccessTokenKey)))
//         }
//         .doMap {
//            $0.accessToken
//         }
//         .doSaveResult()
//         .doInput(UserDefaultsValue.currentUser(nil))
//         .doNext(userDefaultsWorks.loadAssociatedValueWork())
//         .doMap { (userData: UserData) in userData.id }
//         .doMixSaved()
//         .doMap {
//            VKChooseOrgRequest(userId: $0, organizationId: orgId, accessToken: $1)
//         }
//         .doNext(apiUseCase.vkChooseOrg)
//         .onFail(self) {
//            $0.presentErrorPopup()
//         }
//         .doMap {
//            (token: $0.token, sessionId: $0.sessionId)
//         }
//         .doNext(saveLoginResultsWorks.saveLoginResults)
//         .doVoidNext(saveLoginResultsWorks.setFcmToken)
//         .onSuccess {
//            Asset.router?.route(.presentInitial, scene: \.main)
//         }
//   }
   
   private func loginViaVK(code: String, sharedKey: String?) {
      var accessToken = ""
      apiUseCase.vkGetAccessToken
         .doAsync(code)
         .onFail(self) {
            $0.presentErrorPopup()
         }
         .onSuccess { [weak self] in
            self?.apiUseCase.safeStringStorage.applyState(.save((value: $0.accessToken, Config.vkAccessTokenKey)))
         }
         .doMap {
            accessToken = $0.accessToken
            return .login(VKAuthRequest(accessToken: $0.accessToken, sharedKey: sharedKey, token: nil))
         }
         .doNext(apiUseCase.vkAuth)
         .onFail(self) {
            $0.presentErrorPopup()
         }
         .doNext { [weak self] work in
            let input = work.in
            if let token = input.token, let sessionId = input.sessionId {
               work.success((token: token, sessionId: sessionId))
            } else if let organizationsData = input.organizationsData {
               Asset.router?.route(
                  .presentInitial,
                  scene: \.chooseOrgScene,
                  payload: .vkUserOrganizations(organizationsData, accessToken: accessToken)
               )
               work.fail()
            } else {
               self?.presentErrorPopup()
               work.fail()
            }
         }
         .doNext(saveLoginResultsWorks.saveLoginResults)
         .doVoidNext(saveLoginResultsWorks.setFcmToken)
         .onFail(self) {
            $0.presentErrorPopup()
         }
         .doNext(apiUseCase.getUserOrganizations)
         .doNext { work in
            if work.in.count > 0 {
               work.success()
            } else {
               work.fail()
            }
         }
         .onSuccess {
            Asset.router?.route(.presentInitial, scene: \.mainMenu)
            Asset.router?.route(.presentInitial, scene: \.tabBar)
         }
         .onFail {
            Asset.router?.route(.presentInitial, scene: \.onboarding, payload: "")
         }
   }

   private func connectVKAccount(vkCode: String) {
      let token = apiUseCase.safeStringStorage.work
         .doSync(Config.tokenKey)

      apiUseCase.vkGetAccessToken
         .doAsync(vkCode)
         .onFail(self) {
            $0.presentErrorPopup()
         }
         .onSuccess { [weak self] in
            self?.apiUseCase.safeStringStorage.applyState(.save((value: $0.accessToken, Config.vkAccessTokenKey)))
         }
         .doMap {
            .connect(VKAuthRequest(accessToken: $0.accessToken, sharedKey: nil, token: token))
         }
         .doNext(apiUseCase.vkAuth)
         .onFail(self) {
            $0.presentErrorPopup()
         }
         .onSuccess(self) {
            $0.presentSuccessVKConnectPopup()
         }
   }

   private func presentErrorPopup() {
      popupPresenter.setState(.present(
         model: Design.model.common.systemErrorPopup.on(\.didClosed, self) {
            $0.popupPresenter.setState(.hide)
         },
         onView: vcModel?.rootSuperview
      ))
      popupPresenter.on(\.hide) {
         Asset.router?.pop()
      }
   }

   private func presentSuccessVKConnectPopup() {
      let dialogVM = DialogPopupVM<Design>()
      dialogVM.setState(.init(
         title: Design.text.connectVKSucceed,
         buttonText: Design.text.continue
      ))
      dialogVM.didTapButtonWork
         .onSuccess(self) {
            $0.bottomPopupPresenter.setState(.hide)
         }
      bottomPopupPresenter
         .setState(.presentWithAutoHeight(
            model: dialogVM,
            onView: vcModel?.rootSuperview
         ))
      bottomPopupPresenter.on(\.hide) {
         Asset.router?.pop()
      }
   }
}
