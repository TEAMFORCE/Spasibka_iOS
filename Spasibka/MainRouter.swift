//
//  Router.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 03.06.2022.
//

import UIKit

import StackNinja

final class MainRouter<Asset: AssetProtocol>: RouterProtocol, Assetable {
   let nc: UINavigationController

   private var currentNC: UINavigationController { nc.presentedViewController?.navigationController ?? nc }

   private let retainer = Retainer()

   private let bottomSheetTransition = AutoResizingTransitionDelegate()

   init(nc: UINavigationController) {
      self.nc = nc
      nc.view.backgroundColor = Design.color.backgroundBrand
      initColors()
   }

   deinit {
      print("router deinit")
   }

   func start() {
      if Config.isPlaygroundScene {
         route(.push, scene: \.playground, payload: ())
      } else {
         if routeToJoinCommunityIfNeeded() {
            //
         } else if routeToChallengeIfNeeded() {
            //
         } else {
            if UserDefaults.standard.isLoggedIn() {
               routeToMainWithBrandSettingsConfiguration()
            } else {
               route(.presentInitial, scene: \.digitalThanks, payload: ())
               //            route(.presentInitial, scene: \.onboarding, payload: "setixela")
            }
         }
      }
   }
   
   func routeToMainWithBrandSettingsConfiguration() {
      Asset.apiUseCase.loadMyProfile
         .retainBy(retainer)
         .doAsync()
         .onSuccess { user in
            let orgId = user.profile.organizationId
            let appLang = user.profile.language ?? "ru"
            let userDefaultsValue = UserDefaultsValue.appLanguage(appLang)
            
            Asset.apiUseCase.getOrganizationBrandSettings
               .retainBy(self.retainer)
               .doAsync(orgId)
               .doNext(BrandSettings.shared.updateSettingsWork)
               .onAnyResult {
                  Asset.userDefaultsWorks.saveAssociatedValueWork
                     .doAsync(userDefaultsValue)
                     .onAnyResult {
                        self.routeToTheMainMenu()
                     }
               }

         }
         .onFail {
            self.routeToTheMainMenu()
         }
   }
   
   func routeToTheMainMenu() {
      route(.presentInitial, scene: \.mainMenu /*, payload: .normal*/)
      route(.presentInitial, scene: \.tabBar)
   }

   func route<In, Out, T: BaseScene<In, Out> & SMP>(
      _ navType: NavType,
      scene: KeyPath<Scene, T>? = nil,
      payload: T.Input? = nil,
      finishWork: Work<Void, Out>? = nil
   ) {
      switch navType {
      case .push:
         nc.pushViewController(makeVC(routeType: navType), animated: true)
      case .presentInitial:
         nc.viewControllers = [makeVC(routeType: navType)]
      case let .presentModally(value):
         let vc = makeVC(routeType: navType)
         vc.modalPresentationStyle = value
         nc.present(vc, animated: true)
      case let .presentModallyOnPresented(value):
         let vc = makeVC(routeType: navType)
         vc.modalPresentationStyle = value
         if var currentPresented = Optional(nc.presentedViewController) {
            var topPresented: UIViewController?
            while currentPresented != nil {
               topPresented = currentPresented
               currentPresented = currentPresented?.presentedViewController
            }
            topPresented?.present(vc, animated: true)
         } else {
            nc.present(vc, animated: true)
         }
      case .bottomScheet:
         let vc = makeVC(routeType: navType)
         vc.transitioningDelegate = bottomSheetTransition
         vc.modalPresentationStyle = .custom
         nc.present(vc, animated: true)
      }

      // local func
      func makeVC(routeType: NavType) -> UIViewController {
         guard let scene else {
            assertionFailure()
            return .init()
         }

         let sceneModel = Scene()[keyPath: scene]
         sceneModel.setInput(payload)
         let vc = sceneModel.makeVC(routeType: routeType)

         sceneModel.finishWork = finishWork

         return vc
      }
   }

   func pop() {
      nc.popViewController(animated: true)
   }

   func dismissPresented() {
      nc.presentedViewController?.dismiss(animated: true)
   }

   func popToRoot() {
      nc.popToRootViewController(animated: true)
   }

   func initColors() {
      guard let nc = nc as? NavController else { return }

      let brandColor = ProductionAsset.Design.color.backgroundBrand
      let backBrightness = brandColor.brightnessStyle()

      nc
         .backColor(brandColor)
         .barBackColor(ProductionAsset.Design.color.transparent)
         .barTranslucent(true)
         .titleAlpha(1)

      switch backBrightness {
      case .dark:
         nc
            .barStyle(.black)
            .titleColor(ProductionAsset.Design.color.iconInvert)
            .navBarTintColor(ProductionAsset.Design.color.iconInvert)
            .statusBarStyle(.lightContent)
      case .light:
         nc
            .barStyle(.default)
            .titleColor(ProductionAsset.Design.color.textBrand)
            .navBarTintColor(ProductionAsset.Design.color.textBrand)
            .statusBarStyle(.darkContent)
      }
   }

   private func routeToChallengeIfNeeded() -> Bool {
      if let challengeId = UserDefaults.standard.loadString(forKey: .challengeId)?.toInt {
         UserDefaults.standard.clearForKey(.challengeId)

//         route(.presentInitial, scene: \.mainMenu /*, payload: .challengeId(challengeId)*/)
//         route(.presentInitial, scene: \.tabBar)
//         routeToTheMainMenu()
         routeToMainWithBrandSettingsConfiguration()

         return true
      }
      return false
   }

   private func routeToJoinCommunityIfNeeded() -> Bool {
      if let inviteLink = UserDefaults.standard.loadString(forKey: .inviteLink) {
         UserDefaults.standard.clearForKey(.inviteLink)

         let userName: String? = UserDefaults.standard.loadValue(forKey: .userPrivacyAppliedForUserName)

         Asset.apiUseCase.communityInvite
            .retainBy(retainer)
            .doAsync(inviteLink)
            .onSuccess { [weak self] in
               let currentOrgId: Int? = UserDefaults.standard.loadValue(forKey: .currentOrganizationID)
               let orgId = $0.organizationId
               if orgId == currentOrgId, UserDefaults.standard.isLoggedIn() {
//                  self?.route(.presentInitial, scene: \.mainMenu /*, payload: .normal*/)
//                  self?.route(.presentInitial, scene: \.tabBar)
//                  self?.routeToTheMainMenu()
                  self?.routeToMainWithBrandSettingsConfiguration()
                  
               } else {
                  self?.route(
                     .push,
                     scene: \.login,
                     payload: .init(sharedKey: inviteLink, userName: userName)
                  )
               }
            }
            .onFail { [weak self] in
               self?.route(
                  .push,
                  scene: \.login,
                  payload: .init(sharedKey: inviteLink, userName: userName)
               )
            }

         return true
      }

      return false
   }
}

extension MainRouter {
   private var currentVC: UIViewController? { nc.viewControllers.last }
}

extension MainRouter {
   enum LinkObjectType: String {
      case challenge
      case market
      case profile = "other_profile"
   }

   func routeLink(_ url: URL, navType: NavType, isComment: Bool? = nil) {
      guard let parsed = parseToObjectFromLink(url) else {
         print("Error: cannot parse link to route type in func routeLink(_ url: URL, navType: NavType")
         return
      }
      var challengeDetailsChapter: ChallengeDetailsInput.Chapter = .details
      if isComment == true {
         challengeDetailsChapter = .comments
      }
      switch parsed.object {
      case .challenge:
         route(navType, scene: \.challengeDetails, payload: .byId(parsed.id, chapter: challengeDetailsChapter))
      case .market:
         route(navType, scene: \.benefitDetails, payload: (parsed.id, .init(id: parsed.id, name: "")))
      case .profile:
         route(navType, scene: \.profile, payload: parsed.id)
      }
   }

   private func parseToObjectFromLink(_ url: URL) -> (object: LinkObjectType, id: Int)? {
      guard
         let resultTuple = extractEventNamesWithIdFromLinks(url.absoluteString),
         let object = LinkObjectType(rawValue: resultTuple.0)
      else { return nil }

      return (object, resultTuple.1)
   }

   private func extractEventNamesWithIdFromLinks(_ link: String) -> (String, Int)? {
      let linkParts = link.split(separator: "/")
      var objectName = linkParts.last?.toString
      let objectId = objectName?.toInt
      let dropped = linkParts.dropLast()

      if objectId != nil {
         objectName = dropped.last?.toString
      }

      guard let objectName, let objectId else { return nil }

      return (objectName, objectId)
   }
}

extension String {
   func extractURL() -> URL? {
      let types: NSTextCheckingResult.CheckingType = .link
      let detector = try? NSDataDetector(types: types.rawValue)

      guard let detect = detector else {
         return nil
      }

      let matches = detect.matches(in: self, options: .reportCompletion, range: NSMakeRange(0, count))

      return matches.first?.url
   }
}
