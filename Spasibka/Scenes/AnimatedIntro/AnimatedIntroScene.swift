//
//  IntroScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 09.12.2022.
//

import StackNinja
import UIKit

struct AnimatedIntroSceneParams<Asset: AssetProtocol>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = ViewModel
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class AnimatedIntroScene<Asset: ASP>: BaseParamsScene<AnimatedIntroSceneParams<Asset>> {
   //
   private lazy var animation = LottieViewModel()
      .backColor(Design.color.background)
      .name("winter_intro")

   override func start() {
      mainVM
         .addModel(animation) { anchors, superview in
            anchors
               .bottom(superview.bottomAnchor, 50)
               .left(superview.leftAnchor)
               .right(superview.rightAnchor)
         }

      animation.on(\.didFinishAnimation, self) {
         $0.routeNext()
      }

      animation.setState(.play)

      mainVM.view
         .startTapGestureRecognize()
         .on(\.didTap, self) {
            $0.routeNext()
         }
   }
}

private extension AnimatedIntroScene {
   func routeNext() {
      Asset.router?.route(.presentInitial, scene: \.mainMenu)
      Asset.router?.route(.presentInitial, scene: \.tabBar)
   }
}

// MARK: - Lottie View Model

import Lottie

final class LottieViewModel: BaseViewModel<LottieAnimationView> {
   var events = EventsStore()

   override func start() {
      view.contentMode = .scaleAspectFill
   }
}

extension LottieViewModel: Stateable {
   typealias State = ViewState
}

struct LottieEvents: InitProtocol {
   var didFinishAnimation: Void?
}

extension LottieViewModel: Eventable {
   typealias Events = LottieEvents
}

extension LottieViewModel: StateMachine {
   enum ModelState {
      case play
   }

   func setState(_ state: ModelState) {
      switch state {
      case .play:
         view.play { [weak self] _ in
            self?.send(\.didFinishAnimation)
         }
      }
   }
}

extension LottieViewModel {
   @discardableResult
   func name(_ value: String) -> Self {
      let anima = LottieAnimation.named(value)
      view.animation = anima
      return self
   }
}
