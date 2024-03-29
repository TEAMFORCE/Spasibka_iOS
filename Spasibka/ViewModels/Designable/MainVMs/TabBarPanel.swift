//
//  TabBarPanel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.08.2022.
//

import StackNinja
import UIKit

// MARK: - -----------------

final class TabBarPanel<Design: DesignProtocol>: StackModel, Designable {
   // MARK: - View Models

   private(set) lazy var button1 = TabBarButton<Design>()
      .setStates(
         .text(Design.text.main),
         .image(Design.icon.tabBarButton1, Design.color.iconMidpoint)
      )

   private(set) lazy var button2 = TabBarButton<Design>()
      .setStates(
         .text(Design.text.balance),
         .image(Design.icon.tabBarButton2, Design.color.iconMidpoint)
      )

   private(set) lazy var buttonMain: ButtonSelfModable = BottomPanelVMBuilder<Design>.mainButton

   private(set) lazy var button3 = TabBarButton<Design>()
      .setStates(
         .text(Design.text.challenges),
         .image(Design.icon.tabBarButton3, Design.color.iconMidpoint)
      )

   private(set) lazy var button4: ButtonSelfModable = BottomPanelVMBuilder<Design>.button
      .image(Design.icon.tablerDots, color: Design.color.iconMidpoint)

   // MARK: - Private

   private(set) lazy var backImage = TabBarBackImageModel<Design>()

   // MARK: - Start

   override func start() {
      super.start()

    //  safeAreaOffsetDisabled()
      axis(.horizontal)
         .distribution(.equalSpacing)
         .alignment(.center)
         .arrangedModels([
            Grid.xxx.spacer,
            button1,
            button2,
            buttonMain,
            button3,
            button4,
            Grid.xxx.spacer,
         ])

         //.padding(.verticalShift(16.aspected))
         .height(64.aspected)
         .backColor(Design.color.background)
         .cornerRadius(16)
   }
}

struct BottomPanelVMBuilder<Design: DesignProtocol>: Designable {
   static var mainButton: ButtonSelfModable {
      ButtonSelfModable()
         //.safeAreaOffsetDisabled()
         .image(Design.icon.tablerBrandTelegram.withTintColor(.white))
         .size(.square(44.aspected))
         .cornerRadius(44.aspected / 2)
         .backColor(Design.color.backgroundBrand)
         .gradient(
            .init(
               colors: [Design.color.backgroundBrand.withAlphaComponent(0.75), Design.color.backgroundBrandSecondary.withAlphaComponent(0.75)],
               startPoint: .zero,
               endPoint: .init(x: 1, y: 1)
            ),
            size: .init(width: 44.aspected, height: 44.aspected)
         )
   }

   static var button: ButtonSelfModable {
      ButtonSelfModable()
        // .safeAreaOffsetDisabled()
         //
         .width(55)
         .height(36)
         .onModeChanged(\.normal) { button in
//            button.imageTintColor(Design.color.iconBrand)
            button.uiView.layoutIfNeeded()
         }
         .onModeChanged(\.inactive) { button in
//            button.imageTintColor(Design.color.iconMidpoint)
         }
         .setMode(\.inactive)
   }
}

final class TabBarButton<Design: DSP>: Stack<ImageViewModel>.D<LabelModel>.D2<Spacer>.Ninja,
   ModableStackButtonModelProtocol,
   Designable
{
   typealias State = StackState
   typealias State2 = ButtonState

   var modes: ButtonMode = .init()
   var events: EventsStore = .init()

   required init() {
      super.init()

      setAll { image, label, _ in
         image
            .size(.square(20))
            .imageTintColor(Design.color.iconMidpoint)

         label
            .alignment(.center)
            .set(Design.state.label.regular10)
            .numberOfLines(1)
            .textColor(Design.color.textMidpoint)
      }
      alignment(.center)
      spacing(4)
      width(55)
      height(36)

      onModeChanged(\.inactive) { [weak self] in
         self?.models.main.imageTintColor(Design.color.iconMidpoint)
         self?.models.down.textColor(Design.color.textMidpoint)
      }
      onModeChanged(\.normal) { [weak self] in
         print(Design.color.backgroundBrand)
         self?.models.main.imageTintColor(Design.color.backgroundBrand)
         self?.models.down.textColor(Design.color.backgroundBrand)
      }

      view.startTapGestureRecognize()
      view.on(\.didTap, self) {
         self.view.animateTap(uiView: self.view)
         $0.send(\.didTap)
      }
   }
}

enum TabBarButtonState {
   case text(String)
   case image(UIImage, UIColor? = nil)
   case color(UIColor)
}

extension TabBarButton: StateMachine {
   func setState(_ state: TabBarButtonState) {
      switch state {
      case let .text(text):
         models.down
            .text(text)
            .kerning(-0.66)
      case let .image(image, color):
         models.main.image(image, color: color)
      case let .color(color):
         models.main.imageTintColor(color)
         models.down.textColor(color)
      }
   }
}

final class TabBarBackImageModel<Design: DSP>: BaseViewModel<PaddingImageView>, Designable, Stateable2 {
   typealias State = ImageViewState
   typealias State2 = ViewState

   override func start() {
      image(Design.icon.bottomPanel)
      imageTintColor(Design.color.background)
      shadow(Design.params.panelShadow)
   }
}
