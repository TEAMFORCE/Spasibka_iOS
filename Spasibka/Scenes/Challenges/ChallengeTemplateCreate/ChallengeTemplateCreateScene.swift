//
//  ChallengeTemplateCreateScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.07.2023.
//

import StackNinja
import UIKit

final class ChallengeTemplateCreateScene<Asset: AssetProtocol>:
   BaseSceneExtended<ChallengeTemplateCreate<Asset>>, Scenarible2
{
   private lazy var works = ChallengeTemplateCreateWorks<Asset>()

   private(set) lazy var scenario2 = ImagePickingScenario<Asset>(
      works: works,
      stateDelegate: stateDelegate2,
      events: ImagePickingScenarioEvents(
         startImagePicking: addPhotoButton.on(\.didTap),
         addImageToBasket: imagePicker.on(\.didImagePicked),
         removeImageFromBasket: photosPanel.on(\.didCloseImage),
         didMaximumReach: photosPanel.on(\.didMaximumImagesReached)
      )
   )

   // MARK: - View models

   private lazy var titleInput = Design.model.transact.userSearchTextField
      .placeholder(Design.text.nameOfObject)
      .placeholderColor(Design.color.textFieldPlaceholder)

   private lazy var descriptionInput = Design.model.transact.reasonInputTextView
      .placeholder(Design.text.description)
      .placeholderColor(Design.color.textFieldPlaceholder)
      .minHeight(144)

   private lazy var infoBlock = TitleBodyY()
      .setAll { title, body in
         title
            .set(Design.state.label.medium16)
            .text(Design.text.basicInfo)
         body
            .set(Design.state.label.semibold14secondary)
            .text(Design.text.fillChallengeTemplateInfo)
      }
      .alignment(.center)
      .spacing(4)

   private lazy var categoriesBlock = Stack<LabelModel>.R<ImageViewModel>.Ninja()
      .setAll { label, icon in
         label
            .set(Design.state.label.regular14)
            .textColor(Design.color.textSecondary)
            .text(Design.text.categories)
         icon
            .size(.square(24))
            .image(Design.icon.tablerChevronRight)
      }
      .alignment(.center)
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadiusSmall)
      .borderColor(Design.color.iconMidpoint)
      .borderWidth(1)
      .height(Design.params.buttonHeight)
      .padding(.horizontalOffset(16))
   private lazy var categoriesTag = CategoriesTagsScrollModel<Design>()

   private lazy var settingsLabel = LabelModel()
      .set(Design.state.label.medium16)
      .text(Design.text.additionalSettings)
      .textColor(Design.color.textBrand)
      .alignment(.center)
      .makeTappable()

   private lazy var sendButton = Design.model.transact.sendButton
      .set(Design.state.button.inactive)
      .title(Design.text.save)

   // MARK: - Image view models

   private lazy var photosLabel = LabelModel()
      .set(Design.state.label.regular10)
      .text(Design.text.challengeСover.uppercased())
      .textColor(Design.color.textSecondary)
      .kerning(1.5)
      .padLeft(16)
      .hidden(true)
   private lazy var photosPanel = Design.model.transact.pickedImagesPanel
      .hidden(true)
      .maximumImagesCount(1)

   private lazy var addPhotoButton = Design.model.transact.addPhotoButton
      .title(Design.text.challengeСover)
   
   private lazy var deleteLabel = LabelModel()
      .set(Design.state.label.medium16)
      .text(Design.text.deleteChallenge)
      .textColor(Design.color.textError)
      .alignment(.center)
      .makeTappable()
      .hidden(true)

   // MARK: - Activity view models

   private lazy var darkLoader = DarkLoaderVM<Design>()

   private lazy var centerPopupPresenter = Design.model.common.centerPopupPresenter

   // MARK: - Models

   private lazy var imagePicker = Design.model.common.imagePicker

   // MARK: - Start

   override func start() {
      super.start()

      initScenario(.init(
         payload: on(\.input),
         didTitleInputChanged: titleInput.on(\.didEditingChanged),
         didDescriptionInputChanged: descriptionInput.on(\.didEditingChanged),
         didSettingsPressed: settingsLabel.on(\.didTap),
         didCategoriesPressed: categoriesBlock.view.on(\.didTap),
         didSendPressed: sendButton.on(\.didTap),
         didTapDelete: deleteLabel.on(\.didTap)
      ))

      settingsLabel.makeTappable()
      
      mainVM.backColor(Design.color.background)

      mainVM.bodyStack
         .arrangedModels([
            Design.model.common.activityIndicator,
         ])

      mainVM.bodyStack
         .arrangedModels([
            ScrollStackedModelY()
               .set(.spacing(16))
               .set(.arrangedModels([
                  infoBlock,
                  titleInput,
                  descriptionInput,
                  categoriesBlock,
                  categoriesTag.hidden(true),
                  photosLabel,
                  photosPanel,
                  addPhotoButton,
                  Spacer(1),
                  deleteLabel.centeredX(),
                  settingsLabel.centeredX(),
                  Spacer(64),
               ])),
         ])

      mainVM.footerStack
         .arrangedModels([
            sendButton,
         ])

      mainVM.closeButton.on(\.didTap, self) {
         $0.setState(.cancelButtonPressed)
      }

      scenario.configureAndStart()
      scenario2.configureAndStart()

      categoriesBlock.view.startTapGestureRecognize()

      setState(.awaitingState)
   }
}

extension ChallengeTemplateCreateScene: StateMachine {
   func setState(_ state: ModelState) {
      switch state {
      case .readyToInput:
         darkLoader.setState(.hide)
      case .initCreateTemplate:
         mainVM.title.text(Design.text.newTemplate)
         infoBlock.body.text(Design.text.fillChallengeTemplateInfo)
         sendButton.title(Design.text.save)
      case let .initUpdateTemplateWithTemplate(template):
         mainVM.title.text(Design.text.editTemplate)
         infoBlock.body.text(Design.text.fillChallengeTemplateInfo)
         sendButton.title(Design.text.save)
         deleteLabel.hidden(false)

         titleInput.text(template.name.unwrap)
         descriptionInput.text(template.description.unwrap)
      case let .presentLoadedPhoto(image):
         if let image {
            scenario2.events.addImageToBasket.sendAsyncEvent(image)
         }
      case let .updateTitleTextField(text):
         titleInput.text(text)
      case let .updateDescriptTextField(text):
         descriptionInput.text(text)
      case .awaitingState:
         darkLoader.setState(.loading(onView: mainVM.view))
      case .errorState:
         setState(.awaitingState)
         centerPopupPresenter.setState(.present(
            model: Design.model.common.systemErrorPopup
               .on(\.didClosed) { [weak self] in
                  self?.darkLoader.setState(.hide)
                  self?.centerPopupPresenter.setState(.hide)
               },
            onView: vcModel?.view
         ))
      case .dismissScene:
         darkLoader.setState(.hide)
         dismiss()
      case .cancelButtonPressed:
         darkLoader.setState(.hide)
         finishCanceled()
         dismiss()
      case let .setReady(isReady):
         if isReady {
            sendButton.set(Design.state.button.default)
         } else {
            sendButton.set(Design.state.button.inactive)
         }
      case let .routeToSettingsScene(value):
         Asset.router?.route(
            .presentModallyOnPresented(.automatic),
            scene: \.challengeSettings,
            payload: value
         )
      case .challengeCreated:
         darkLoader.setState(.hide)
         finishSucces()
         dismiss()
      case let .routeToCategories(input):
         Asset.router?.route(
            .presentModallyOnPresented(.automatic),
            scene: \.categories,
            payload: input,
            finishWork: scenario.events.didSelectCategories
         )
      case .presentCategoriesTags(let categories):
         let models = categories.map {
            CategoryTagModel<Design>()
               .text($0.name)
         }
         categoriesTag.setState(models)
      case .challengeDeleted:
         darkLoader.setState(.hide)
         finishSucces()
         dismiss()
      }
   }
}

extension ChallengeTemplateCreateScene: StateMachine2 {
   func setState2(_ state: ImagePickingState) {
      switch state {
      case let .presentPickedImage(image):
         photosLabel.hidden(false)
         photosPanel.hidden(false)
         photosPanel.addImage(image)
         darkLoader.setState(.hide)
      case let .setHideAddPhotoButton(value):
         addPhotoButton.hidden(value)
      case let .setHidePanel(value):
         photosLabel.hidden(value)
         photosPanel.hidden(value)
      case .presentImagePickerWithLimit:
         guard let baseVC = vcModel else { return }

         setState(.awaitingState)
         imagePicker
            .send(\.presentOn, baseVC)
            .on(\.didCancel, self) {
               $0.darkLoader.setState(.hide)
            }
      case .presentImagePicker:
         break
      }
   }
}
