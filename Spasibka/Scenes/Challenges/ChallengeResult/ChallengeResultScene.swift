//
//  ChallengeResultScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.10.2022.
//

import StackNinja

enum ChallengeResultSceneState {
   case initial

   case sendingEnabled
   case sendingDisabled

   case uploading
   case popScene

   case finishWithSentResult

   case setInputText(String)

   case error
}

extension DefaultVCModel {
   func dismissOrPop(animated: Bool = true) {
      if let navigationController {
         navigationController.popViewController(animated: animated)
      } else {
         dismiss(animated: animated)
      }
   }
}

final class ChallengeResultScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   NavbarBodyFooterStack<Asset, PresentPush>,
   Asset,
   Int,
   Void
>, Scenarible2 {
//
   private let works = ChallengeResultWorks<Asset>()

   lazy var scenario = ChallengeResultScenario<Asset>(
      works: works,
      stateDelegate: stateDelegate,
      events: ChallengeResultEvents(
         saveInput: on(\.input),
         commentInputChanged: inputModel.on(\.didEditingChanged),
         sendResult: sendButton.on(\.didTap)
      )
   )

   lazy var scenario2 = ImagePickingScenario<Asset>(
      works: works,
      stateDelegate: stateDelegate2,
      events: ImagePickingScenarioEvents(
         startImagePicking: addPhotoButton.on(\.didTap),
         addImageToBasket: imagePicker.on(\.didImagePicked),
         removeImageFromBasket: photosPanel.on(\.didCloseImage),
         didMaximumReach: photosPanel.on(\.didMaximumImagesReached)
      )
   )

   private lazy var inputModel = Design.model.transact.reasonInputTextView
      .placeholder(Design.text.comment)
      .height(166)

   private lazy var photosPanel = Design.model.transact.pickedImagesPanel
      .maximumImagesCount(10)
      .hidden(true)

   private lazy var addPhotoButton = Design.model.transact.addPhotoButton
   private lazy var sendButton = Design.model.transact.sendButton

   private lazy var imagePicker = Design.model.common.imagePickerExtended
   
   private lazy var darkLoader = DarkLoaderVM<Design>()
   private lazy var alertPresenter = CenterPopupPresenter()
   private lazy var errorPopup = Design.model.common.systemErrorPopup

   override func start() {
      super.start()

      mainVM.navBar.titleLabel
         .text(Design.text.result)

      mainVM.bodyStack
         .padHorizontal(16)
         .spacing(Grid.x16.value)
         .arrangedModels(Design.model.common.activityIndicator)

      configure()
   }

   private func configure() {
      setState(.initial)

      mainVM.navBar.backButton
         .on(\.didTap, self) {
            $0.vcModel?.dismissOrPop()
            $0.finishWork?.fail()
         }

      scenario.configureAndStart()
      scenario2.configureAndStart()
   }
}

extension ChallengeResultScene {
   func setState(_ state: ChallengeResultSceneState) {
      switch state {
      case .initial:
         mainVM.bodyStack
            .arrangedModels(
               inputModel,
               photosPanel,
               addPhotoButton,
               Spacer()
            )
         mainVM.footerStack
            .arrangedModels(
               Grid.x16.spacer,
               sendButton
            )
         mainVM.view.setNeedsLayout()
         darkLoader.setState(.hide)
      case .sendingEnabled:
         sendButton.set(Design.state.button.default)
         darkLoader.setState(.hide)
      case .sendingDisabled:
         sendButton.set(Design.state.button.inactive)
      case .uploading:
         darkLoader.setState(.loading(onView: vcModel?.view.superview))
      case .popScene:
         darkLoader.setState(.hide)
         vcModel?.dismissOrPop()
      case .finishWithSentResult:
         darkLoader.setState(.hide)
         vcModel?.dismissOrPop()
         finishWork?.success()
      case let .setInputText(text):
         inputModel.text(text)
      case .error:
         darkLoader.setState(.hide)
         alertPresenter.setState(.present(model: errorPopup, onView: vcModel?.view))
         errorPopup.on(\.didClosed, self) {
            $0.alertPresenter.setState(.hide)
         }
      }
   }
}

extension ChallengeResultScene: StateMachine2 {
   func setState2(_ state: ImagePickingState) {
      switch state {
      //
      case let .presentPickedImage(image):
         photosPanel.addImage(image)
         setState2(.setHidePanel(false))
      //
      case let .setHideAddPhotoButton(value):
         addPhotoButton.hiddenAnimated(value, duration: 0.2)
         //
      case let .setHidePanel(value):
         photosPanel.hiddenAnimated(value, duration: 0.2)
      case .presentImagePickerWithLimit(limit: let limit):
         guard let baseVC = vcModel else { return }
         imagePicker
            .setLimit(limit)
            .send(\.presentOn, baseVC)
      case .presentImagePicker:
         break
      }
   }
}
