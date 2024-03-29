//
//  TabBarScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.02.2024.
//

import StackNinja
import UIKit

struct TabBarSceneInput {
   struct BarButton {
      let sceneModel: AnyKeyPath
      let title: String
      var icon: UIImage
      let route: NavType
   }

   let sceneModels: [BarButton]
   let customButton: ButtonSelfModable?
}

final class TabBarScene<Asset: ASP>: BaseSceneModel<
   TabBarVC<Asset>,
   StackModel,
   Asset,
   TabBarSceneInput?,
   Void
> {
   private let bottomOffset: CGFloat = 16
   private let tabBarHeight: CGFloat = 68

   private var sceneModels: [TabBarSceneInput.BarButton] = []

   private lazy var mainButton =
      ButtonSelfModable()
         .image(Design.icon.tablerBrandTelegram.withTintColor(.white))
         .size(.square(44.aspected))
         .cornerRadius(44.aspected / 2)
         .backColor(Design.color.backgroundBrand)
         .gradient(
            .init(
               colors: [
                  Design.color.backgroundBrand.withAlphaComponent(0.75),
                  Design.color.backgroundBrandSecondary.withAlphaComponent(0.75)
               ],
               startPoint: .zero,
               endPoint: .init(x: 1, y: 1)
            ),
            size: .init(width: 44.aspected, height: 44.aspected)
         )
   private lazy var buttons: [TabBarSceneInput.BarButton] = [
      .init(
         sceneModel: \ProductionAsset.Scene.mainMenu,
         title: Design.text.main,
         icon: Design.icon.tabBarButton1,
         route: .presentInitial
      ),
      .init(
         sceneModel: \ProductionAsset.Scene.balance,
         title: Design.text.balance,
         icon: Design.icon.tabBarButton2,
         route: .presentInitial
      ),
      .init(
         sceneModel: \ProductionAsset.Scene.transactions,
         title: "",
         icon: Design.icon.tablerBrandTelegram.withTintColor(Design.color.transparent),
         route: .push
      ),
      .init(
         sceneModel: \ProductionAsset.Scene.challengesGroup,
         title: Design.text.challenges,
         icon: Design.icon.tabBarButton3,
         route: .presentInitial
      ),
      .init(
         sceneModel: \ProductionAsset.Scene.market,
         title: Design.text.benefit,
         icon: Design.icon.basket,
         route: .presentInitial
      )
   ]

   private lazy var defaultInput = TabBarSceneInput(sceneModels: buttons, customButton: mainButton)

   override func start() {
      super.start()

      guard
//         let scenes = inputValue?.sceneModels,
         let vcModel = vcModel
      else { return }
      let scenes = defaultInput.sceneModels

      sceneModels = scenes

      vcModel.tabBar.tintColor = Design.color.iconBrand
      vcModel.tabBar.unselectedItemTintColor = Design.color.iconSecondary
      if let customButton = defaultInput.customButton?.uiView {
         vcModel.tabBar.addSubview(customButton)
         NSLayoutConstraint.activate([
            customButton.centerXAnchor.constraint(equalTo: vcModel.tabBar.centerXAnchor),
            customButton.centerYAnchor.constraint(equalTo: vcModel.tabBar.centerYAnchor)
         ])
      }
      let sideOffset: CGFloat = 12
      let count = scenes.count.cgFloat
      let step = sideOffset * 2 / count
      var offset = sideOffset
      let ncs = scenes
         .enumerated()
         .compactMap {
            if $1.route == .presentInitial,
               let sceneModel = ProductionAsset.Scene()[keyPath: $1.sceneModel] as? SceneModelProtocol
            {
               let vc = sceneModel.makeVC(routeType: .presentInitial)

               let image = $1.icon.resized(to: CGSize(width: 20, height: 20))
               let item = UITabBarItem(title: $1.title, image: image, tag: $0)
               let attributes = [NSAttributedString.Key.font: Design.font.descriptionRegular10]
               item.setTitleTextAttributes(attributes, for: .normal)
               item.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)
               item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -sideOffset)

               vc.tabBarItem = item
               offset -= step
               return (vc, $1.route.rawValue)
            } else {
               return (UIViewController(), $1.route.rawValue)
            }
         }
      
      let ncs1 = ncs.map {
         let navCon = NavController(nibName: nil, bundle: nil)
            .barStyle(.default)
            .statusBarStyle(.darkContent)
            .disableAutomaticChangeColors()

         navCon.setNavigationBarHidden(true, animated: false)
         navCon.setViewControllers([$0], animated: false)
         navCon.restorationIdentifier = $1
         return navCon
      }

      vcModel.setViewControllers(ncs1, animated: false)

      let tabBar = vcModel.tabBar

      tabBar.itemPositioning = UITabBar.ItemPositioning.centered

      ViewModel()
         .backColor(Design.color.background)
         .cornerCurve(.continuous)
         .cornerRadius(Design.params.cornerRadius)
         .shadow(Design.params.panelShadow)
         .view
         .insertToSuperview(vcModel.tabBar)
         .fitToView(tabBar)

      vcModel
         .on(\.viewDidLayoutSubviews, self) {
            guard
               let view = vcModel.view
            else { return }

            var tabFrame = tabBar.frame
            tabFrame.size.height = $0.tabBarHeight
            tabFrame.origin.x = sideOffset
            tabFrame.origin.y = view.frame.size.height
               - ($0.tabBarHeight + $0.bottomOffset + view.safeAreaInsets.bottom * 0.5)
            tabFrame.size.width = tabFrame.width - sideOffset * 2
            tabBar.frame = tabFrame
         }
         .on(\.requestVCAtIndex) { [weak self] tuple in
            guard let self else { return }

            let sceneKey = self.sceneModels[tuple.0].sceneModel
            if let sceneModel = ProductionAsset.Scene()[keyPath: sceneKey] as? SceneModelProtocol {
               tuple.1(sceneModel.makeVC(routeType: .presentInitial))
            }
         }
         .on(\.requestVCAtIndexPush) { [weak self] tuple in
            guard let self else { return }

            let sceneKey = self.sceneModels[tuple.0].sceneModel
            if let sceneModel = ProductionAsset.Scene()[keyPath: sceneKey] as? SceneModelProtocol {
               tuple.1(sceneModel.makeVC(routeType: .push))
            }
         }
   }
}

class TabBarVC<Asset: ASP>: UITabBarController, VCModelProtocol, UITabBarControllerDelegate, Eventable2 {
   var events2 = EventsStore()

   var currentBackColor: UIColor?
   var currentStatusBarStyle: UIStatusBarStyle?
   var currentBarStyle: UIBarStyle?
   var currentBarTintColor: UIColor?
   var currentTitleColor: UIColor?
   var currentBarTranslucent: Bool?
   var currentBarBackColor: UIColor?
   var currentTitleAlpha: CGFloat?

   private(set) var isFirstAppear: Bool = true

   let sceneModel: SceneModelProtocol

   struct Events2: InitProtocol {
      var requestVCAtIndex: (Int, (UIViewController) -> Void)?
      var requestVCAtIndexPush: (Int, (UIViewController) -> Void)?
   }

   required init(sceneModel: SceneModelProtocol) {
      self.sceneModel = sceneModel

      super.init(nibName: nil, bundle: nil)
   }

   @available(*, unavailable)
   required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }

   override func viewDidLoad() {
      super.viewDidLoad()

      DispatchQueue.main.async { [weak self] in
         self?.delegate = self
         self?.sceneModel.start()
      }
   }

   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      send(\.viewWillAppear)
   }

   override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()

      send(\.viewWillLayoutSubviews)
   }

   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      send(\.viewDidLayoutSubviews)
   }

   var events: EventsStore = .init()

   func tabBarController(_: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
      guard let identifier = viewController.restorationIdentifier else { return true }

      if identifier == NavType.presentModally(.none).rawValue {
         let index = viewControllers?.firstIndex(of: viewController) ?? 0
         send(\.requestVCAtIndex, (index, { [weak self] vc in
            self?.present(vc, animated: true, completion: nil)
         }))

         return false
      }

      if identifier == NavType.push.rawValue {
         let index = viewControllers?.firstIndex(of: viewController) ?? 0
         send(\.requestVCAtIndexPush, (index, { [weak self] vc in
            self?.navigationController?.pushViewController(vc, animated: true)
         }))
         return false
      }

      return true
   }
}
