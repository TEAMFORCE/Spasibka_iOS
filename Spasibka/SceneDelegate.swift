//
//  SceneDelegate.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 17.06.2022.
//

import StackNinja
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
   var window: UIWindow?

   var router: (any RouterProtocol)?

   func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options: UIScene.ConnectionOptions) {
      guard let windowScene = (scene as? UIWindowScene) else { return }

      if let userActivity = options.userActivities.first {
         parseDiplinkActivity(userActivity)
      }

      let window = UIWindow(windowScene: windowScene)
      let nc = NavController(nibName: nil, bundle: nil)

      startDispatcher(nc)

      window.rootViewController = nc
      self.window = window
      window.makeKeyAndVisible()
   }

   func sceneDidDisconnect(_: UIScene) {}
   func sceneDidBecomeActive(_: UIScene) {}
   func sceneWillResignActive(_: UIScene) {}
   func sceneWillEnterForeground(_: UIScene) {}
   func sceneDidEnterBackground(_: UIScene) {}

   func scene(_: UIScene, continue userActivity: NSUserActivity) {
      if parseDiplinkActivity(userActivity) {
         ProductionAsset.router?.start()
      }
   }

   func reload() {
      let nc = NavController(nibName: nil, bundle: nil)

      startDispatcher(nc)

      self.window?.rootViewController = nc

   }
   @discardableResult
   private func parseDiplinkActivity(_ userActivity: NSUserActivity) -> Bool {
      guard
         userActivity.activityType == NSUserActivityTypeBrowsingWeb,
         let urlToOpen = userActivity.webpageURL
      else {
         return false
      }

      var parameters: [String: String] = [:]
      var urlPath: [String] = []

      URLComponents(url: urlToOpen, resolvingAgainstBaseURL: false)?
         .queryItems?
         .forEach {
            parameters[$0.name] = $0.value
         }
      
      urlToOpen.pathComponents.forEach { urlPath.append($0) }
      
      for (i, path) in urlPath.enumerated() {
         if path == "challenge" {
            if let challengeId = urlPath[safe: i+1] {
               UserDefaults.standard.saveString(challengeId, forKey: .challengeId)
               return true
            }
         }
      }
      
      if let data = parameters["invite"] {
         UserDefaults.standard.saveString(data, forKey: .inviteLink)

         return true
      }

      return false
   }
}

private extension SceneDelegate {
   func startDispatcher(_ nc: NavController) {
      router = ProductionAsset.makeRouter(with: nc)
      window?.backgroundColor = ProductionAsset.Design.color.backgroundBrand
      router?.start()
   }
}

extension AssetProtocol {
   static func makeRouter(with nc: NavController) -> any RouterProtocol {
      let router = MainRouter<Asset>(nc: nc)
      self.router = router
      return router
   }
}

final class NavController: UINavigationController, UINavigationControllerDelegate {
   private var currentStatusBarStyle: UIStatusBarStyle?
   private var currentBarStyle: UIBarStyle?
   private var currentBarTintColor: UIColor?
   private var currentTitleColor: UIColor?
   private var currentBarTranslucent: Bool?
   private var currentBarBackColor: UIColor?
   private var currentBackColor: UIColor?
   private var currentTitleAlpha: CGFloat?

   override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
      super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

      delegate = self
   }

   @available(*, unavailable)
   required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   override func viewDidLoad() {
      super.viewDidLoad()

      navigationBar.setBackgroundImage(UIImage(), for: .default)
      navigationBar.shadowImage = UIImage()
      navigationBar.isTranslucent = true
      navigationBar.backgroundColor = .clear
      extendedLayoutIncludesOpaqueBars = true
   }

   private var visibleVCModel: (any VCModelProtocol)? {
      visibleViewController as? any VCModelProtocol
   }

   override var preferredStatusBarStyle: UIStatusBarStyle {
      if let vc = visibleVCModel {
         return vc.currentStatusBarStyle ?? currentStatusBarStyle ?? .default
      } else {
         return currentStatusBarStyle ?? .default
      }
   }

   func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
      if let vc = viewController as? any VCModelProtocol {
         if vc.currentBarStyle == nil, let currentBarStyle {
            barStyle(currentBarStyle)
         }
         if vc.currentBarTintColor == nil, let currentBarTintColor {
            navBarTintColor(currentBarTintColor)
         }
         if vc.currentTitleColor == nil, let currentTitleColor {
            titleColor(currentTitleColor)
         }
         if vc.currentTitleAlpha == nil, let currentTitleAlpha {
            titleAlpha(currentTitleAlpha)
         }
         if vc.currentBarTranslucent == nil, let currentBarTranslucent {
            barTranslucent(currentBarTranslucent)
         }
         if vc.currentBarBackColor == nil, let currentBarBackColor {
            barBackColor(currentBarBackColor)
         }
         if vc.currentBackColor == nil, let currentBackColor {
            backColor(currentBackColor)
         }
      }
   }
}

extension NavController {
   @discardableResult func barStyle(_ value: UIBarStyle) -> Self {
      currentBarStyle = value
      navigationBar.barStyle = value
      return self
   }

   @discardableResult func navBarTintColor(_ value: UIColor) -> Self {
      currentBarTintColor = value
      navigationBar.barTintColor = value
      navigationBar.tintColor = value
      return self
   }

   @discardableResult func statusBarStyle(_ value: UIStatusBarStyle) -> Self {
      currentStatusBarStyle = value
      setNeedsStatusBarAppearanceUpdate()
      return self
   }

   @discardableResult func titleColor(_ value: UIColor) -> Self {
      currentTitleColor = value
      let textAttributes = [NSAttributedString.Key.foregroundColor: value]
      navigationBar.titleTextAttributes = textAttributes
      return self
   }

   @discardableResult func barTranslucent(_ value: Bool) -> Self {
      currentBarTranslucent = value
      navigationBar.isTranslucent = value
      return self
   }

   @discardableResult func barBackColor(_ value: UIColor) -> Self {
      currentBarBackColor = value
      navigationBar.backgroundColor = value
      return self
   }

   @discardableResult func titleAlpha(_ value: CGFloat) -> Self {
      currentTitleAlpha = value
      navigationItem.titleView?.alpha = value
      return self
   }

   @discardableResult func backColor(_ value: UIColor) -> Self {
      currentBackColor = value
      view.backgroundColor = value
      return self
   }

   @discardableResult func disableAutomaticChangeColors() -> Self {
      let navigationBarAppearance = UINavigationBarAppearance()

      navigationBarAppearance.configureWithTransparentBackground()
      navigationBarAppearance.titleTextAttributes = [
         NSAttributedString.Key.foregroundColor : currentTitleColor ?? .white
      ]

      UINavigationBar.appearance().standardAppearance = navigationBarAppearance
      UINavigationBar.appearance().compactAppearance = navigationBarAppearance
      UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

      return self
   }
}
