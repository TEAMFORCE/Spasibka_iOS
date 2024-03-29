//
//  MainMenuScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 24.01.2024.
//

import StackNinja
import UIKit

struct MainMenuSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = AnimatedHeaderNavbarBodyFooterStack<Asset>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class MainMenuScene<Asset: AssetProtocol>: BaseParamsScene<MainMenuSceneParams<Asset>> {
   private lazy var mainMenuViewModel = MainMenuSceneViewModel<Asset>()

   var headerBrightness: ColorBrightnessStyle = .dark
   var headerHeightConstraint: NSLayoutConstraint?
   var headerViewModel: some ViewModelProtocol & AnyObject { mainMenuViewModel.headerViewModel }

   override func start() {
      mainVM.headerStack
         .arrangedModels(mainMenuViewModel.headerViewModel)
      mainVM.bodyStack
         .backColor(Design.color.background)
         .arrangedModels(mainMenuViewModel.scrollWrapper)

      let view = mainVM.view
      // add gestures up and down for hide and present header
      let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
      view.addGestureRecognizer(panGesture)

      mainMenuViewModel.scrollWrapper.on(\.willEndDragging, self) {
         if $1.velocity <= 0, !$0.isHeaderPresented {
            $0.presentHeaderAll()
         } else if $1.velocity > 0, $0.isHeaderPresented {
            $0.hideHeaderAll()
         }
      }

      mainMenuViewModel.scenarioStart()

      mainMenuViewModel.headerViewModel
         .on(\.didTapAvatar) {
            Asset.router?.route(.push, scene: \.myProfile)
         }
         .on(\.didTapNotifications) {
            Asset.router?.route(.push, scene: \.notifications)
         }

      presentHeaderAll()
      
      vcModel?.on(\.viewWillAppear, self) {
         $0.mainMenuViewModel.reloadNotificationsAmount()
      }
   }

   var maxHeaderHeight: CGFloat { topSafeAreaInset() + 260.aspected }
   var minHeaderHeight: CGFloat { topSafeAreaInset() + 86 }

   var isNavBarEnabled: Bool { false }

   private func presentHeaderAll() {
      presentHeader {}
   }

   private func hideHeaderAll() {
      hideHeader {}
   }

   @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
      let translation = sender.translation(in: mainVM.view)
      if translation.y > 0 {
         presentHeaderAll()
      } else if translation.y < 0 {
         hideHeaderAll()
      }
   }
}

extension MainMenuScene: NewHeaderAnimatedSceneProtocol {}
