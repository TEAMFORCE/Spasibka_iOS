//
//  ChallengeCreateScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 11.10.2022.
//

import StackNinja
import UIKit

struct ChallengeCreateEvents: InitProtocol {
   var cancelled: Void?
   var continueButtonPressed: Void?
   var finishWithSuccess: Void?
   var finishWithError: Void?
}

enum ChallengeCreateSceneState {
   case initCreateChallenge
   case initCreateChallengeWithTemplate(ChallengeTemplate)
   case initEditChallenge(Challenge)

   case awaitingState
   case readyToInput
   case errorState
   case dismissScene
   case cancelButtonPressed
   case setReady(Bool)

   case updateMinimumDate(Date?)

   case challengeCreated
   case challengeDeleted

   case presentSettingsScene(ChallengeSettings)

   case updateTitleTextField(String)
   case updateDescriptTextField(String)

   case challengeUpdated

   case setFondAccountValues(ChallengeSettings)
   case updateDelayedStart(Bool)
   case imagesToBasket([UIImage])
   case setImageURLsToBasket([String])
   case hideBalanceAccount(Bool)
}

enum ChallengeCreateInput {
   case createChallenge
   case createChallengeWithTemplate(ChallengeTemplate)
   case editChallenge(Challenge)
}

final class ChallengeCreateScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   NavbarBodyFooterStack<Asset, PresentPush>,
   Asset,
   ChallengeCreateInput,
   FinishEditChallengeEvent
>, Scenarible2 {
   private lazy var works = ChallengeCreateWorks<Asset>()
   lazy var scenario = ChallengeCreateScenario<Asset>(
      works: works,
      stateDelegate: stateDelegate,
      events: ChallengeCreateScenarioEvents(
         payload: on(\.input),
         didTitleInputChanged: titleInput.wrappedModel.on(\.didEditingChanged),
         didDescriptionInputChanged: descriptionInput.wrappedModel.on(\.didEditingChanged),
         didPrizeFundChanged: prizeFundInput.wrappedModel.models.main.on(\.didEditingChanged),
         didStartDatePicked: startDatePicker.wrappedModel.on(\.didDatePicked),
         didStartDateCleared: startDatePicker.wrappedModel.on(\.didClearDate),
         didFinishDatePicked: finishDatePicker.wrappedModel.on(\.didDatePicked),
         didFinishDateCleared: finishDatePicker.wrappedModel.on(\.didClearDate),
         didSendPressed: sendButton.on(\.didTap),
         didPrizePlaceInputChanged: prizePlacesInput.wrappedModel.on(\.didEditingChanged),
         openSettingsScene: settingsLabel.on(\.didTap),
         didTapDelete: deleteLabel.on(\.didTap),
         didSelectFondAccountIndex: fondAccountDropDownVM.on(\.didSelectItemAtIndex),
         delayedStartChanged: delayedStartLabel.on(\.didSelected),
         balanceAccountHide: balanceAccountLabel.on(\.didSelected),
         didDeleteImageAtIndex: photosPanel.on(\.didDeleteViewModelAtIndex),
         didMoveImage: photosPanel.on(\.didMoveViewModel)
      )
   )

   lazy var scenario2 = SortableImagePickingScenario<Asset>(
      works: works,
      stateDelegate: stateDelegate2,
      events: SortableImagePickingScenarioEvents(
         startImagePicking: addPhotoButton.on(\.didTap),
         addImageToBasket: imagePicker.on(\.didImagePicked),
         removeImageFromBasketAtIndex: photosPanel.on(\.didDeleteViewModelAtIndex),
         moveImage: photosPanel.on(\.didMoveViewModel),
         didMaximumReach: .init()
      )
   )

//   private lazy var infoBlock = TitleBodyY()
//      .setAll { title, body in
//         title
//            .set(Design.state.label.medium16)
//            .text(Design.text.basicInfo)
//         body
//            .set(Design.state.label.semibold14secondary)
//            .text(Design.text.fillChallengeInfo)
//      }
//      .alignment(.center)
//      .spacing(4)

   private lazy var titleInput = TitleStarredInputModel<Design, TextFieldModel>(
      title: Design.text.title,
      wrappedModel: Design.model.transact.userSearchTextField
         .placeholder(Design.text.nameOfObject)
         .placeholderColor(Design.color.textFieldPlaceholder)
   )

   private lazy var descriptionInput = TitleStarredInputModel<Design, TextViewModel>(
      title: Design.text.description,
      wrappedModel: Design.model.transact.reasonInputTextView
         .placeholder(Design.text.description)
         .placeholderColor(Design.color.textFieldPlaceholder)
         .minHeight(144)
   )

   private lazy var startDatePicker = TitleStarredInputModel<Design, DropDownDatePickerVM>(
      title: Design.text.challDateOfStart,
      wrappedModel: DropDownDatePickerVM<Design>()
         .setStates(
            .titleText(Design.text.challDateOfStart),
            .datePickerMode(.dateAndTime)
         )
   )

   private lazy var finishDatePicker = TitleStarredInputModel<Design, DropDownDatePickerVM>(
      title: Design.text.challDateOfCompletion,
      wrappedModel: DropDownDatePickerVM<Design>()
         .setStates(
            .titleText(Design.text.challDateOfCompletion),
            .datePickerMode(.dateAndTime)
         )
   )

   private typealias PrizeFundInput = Stack<TextFieldModel>.R<Spacer>.R2<ImageViewModel>.Ninja
   private lazy var prizeFundInput = TitleStarredInputModel<Design, PrizeFundInput>(
      title: Design.text.setPrizeFund,
      wrappedModel: PrizeFundInput()
         .setAll { input, _, icon in
            input
               .set(Design.state.textField.invisible)
               .set(.placeholder(Design.text.setPrizeFund))
               .placeholderColor(Design.color.textFieldPlaceholder)
               .clearButtonMode(.never)
               .onlyDigitsMode()
               .keyboardType(.numberPad)
            icon
               .size(.square(24))
               .image(Design.icon.smallSpasibkaLogo, color: Design.color.iconMidpoint)
         }
         .cornerCurve(.continuous)
         .cornerRadius(Design.params.cornerRadiusMini)
         .borderColor(Design.color.iconMidpoint)
         .borderWidth(1)
         .height(Design.params.buttonHeight)
         .padding(.horizontalOffset(16))
   )

   private lazy var prizePlacesInput = TitleStarredInputModel<Design, TextFieldModel>(
      title: Design.text.setAwardeesCount,
      wrappedModel: TextFieldModel()
         .set(Design.state.textField.default)
         .placeholder(Design.text.setAwardeesCount)
         .placeholderColor(Design.color.textFieldPlaceholder)
         .onlyDigitsMode()
         .keyboardType(.numberPad)
   )

   private lazy var photosLabel = LabelModel()
      .set(Design.state.label.regular10)
      .text(Design.text.challengeСover.uppercased())
      .textColor(Design.color.textSecondary)
      .kerning(1.5)
      .padLeft(16)
      .hidden(true)

   private lazy var photosPanel = DragAndDropCarouselViewModel<Design>(superView: vcModel?.rootSuperview)

   private lazy var addPhotoButton = Design.model.transact.addPhotoButton
      .title(Design.text.addPhoto)

   private lazy var sendButton = Design.model.transact.sendButton
      .set(Design.state.button.inactive)
      .title(Design.text.create)

   private lazy var cancelButton = Design.button.transparent
      .title(Design.text.cancel)

   private lazy var activityIndicator = Design.model.common.activityIndicator
   private lazy var imagePicker = Design.model.common.imagePickerExtended

   private lazy var darkLoader = DarkLoaderVM<Design>()

   private lazy var settingsLabel = LabelModel()
      .set(Design.state.label.descriptionRegular16)
      .text(Design.text.additionalSettings)
      .textColor(Design.color.text)
      .alignment(.center)
      .makeTappable()

   private lazy var deleteLabel = LabelModel()
      .set(Design.state.label.medium16)
      .text(Design.text.deleteChallenge)
      .textColor(Design.color.textError)
      .alignment(.center)
      .makeTappable()
      .hidden(true)

   private lazy var balanceAccountLabel = CheckMarkLabel<Design>()
      .setStates(
         .text(Design.text.changeFond)
      )

   private lazy var fondAccountDropDownVM = DropDownSelectorVM<Design>()
      .setStates(
         .titleText(Design.text.balance)
      )
      .hidden(true)

   private lazy var delayedStartLabel = CheckMarkLabel<Design>()
      .setStates(
         .text(Design.text.delayedStart)
      )

   private lazy var centerPopupPresenter = Design.model.common.centerPopupPresenter

   // MARK: - Start

   override func start() {
      super.start()

      mainVM.bodyStack
         .padHorizontal(Design.params.commonSideOffset)
         .arrangedModels([
            ScrollStackedModelY()
               .set(.spacing(16))
               .set(.arrangedModels([
                  titleInput.warningStarHidden(false),
                  descriptionInput,

                  delayedStartLabel,

                  startDatePicker
                     .hidden(true),
                  finishDatePicker,

                  prizeFundInput.warningStarHidden(false),
                  prizePlacesInput.warningStarHidden(false),

                  balanceAccountLabel,
                  fondAccountDropDownVM,

                  photosLabel,
                  photosPanel,
                  addPhotoButton,

                  Spacer(1),

                  settingsLabel.centeredX(),
                  deleteLabel.centeredX(),

                  Spacer(64)
               ]))
         ])

      mainVM.footerStack
         .arrangedModels([
            sendButton
         ])

      mainVM.navBar
         .backButton.on(\.didTap, self) {
            $0.setState(.cancelButtonPressed)
         }

      finishDatePicker.wrappedModel.setState(.minimumDate(Date()))

      scenario.configureAndStart()
      scenario2.configureAndStart()

      setState(.awaitingState)
   }
}

extension ChallengeCreateScene {
   func setState(_ state: ChallengeCreateSceneState) {
      switch state {
      case .awaitingState:
         darkLoader.setState(.loading(onView: mainVM.view))

      case .readyToInput:
         darkLoader.setState(.hide)

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

      case let .setReady(isReady):
         if isReady {
            sendButton.set(Design.state.button.default)
         } else {
            sendButton.set(Design.state.button.inactive)
         }

      case .cancelButtonPressed:
         darkLoader.setState(.hide)
         finishCanceled()
         dismiss()

      case .challengeCreated:
         darkLoader.setState(.hide)
         finishSucces(.didCreate)
         dismiss()

      case .challengeUpdated:
         darkLoader.setState(.hide)
         finishSucces(.didEdit)
         dismiss()

      case .challengeDeleted:
         darkLoader.setState(.hide)
         finishSucces(.didDelete)
         dismiss()

      case let .presentSettingsScene(value):
         Asset.router?.route(
            .presentModally(.automatic),
            scene: \.challengeSettings,
            payload: value
         )

      case let .updateTitleTextField(text):
         titleInput.wrappedModel.text(text)

      case let .updateDescriptTextField(text):
         descriptionInput.wrappedModel.text(text)

      case let .updateMinimumDate(date):
         if let date {
            finishDatePicker.wrappedModel.setStates(
               .minimumDate(date),
               .clearDate
            )
         }

      case let .initCreateChallengeWithTemplate(template):
         mainVM.navBar.titleLabel.text(Design.text.createChallenge)
         titleInput.wrappedModel.text(template.name.unwrap)
         descriptionInput.wrappedModel.text(template.description.unwrap)

      case .initCreateChallenge:
         mainVM.navBar.titleLabel.text(Design.text.createChallenge)

      case let .initEditChallenge(value):
         mainVM.navBar.titleLabel.text(Design.text.editChallengeTitle)
         titleInput.wrappedModel.text(value.name.unwrap)
         descriptionInput.wrappedModel.text(value.description.unwrap)
         sendButton.title(Design.text.save)
         deleteLabel.hidden(false)
         if value.challengeCondition == .A, value.approvedReportsAmount > 0 || value.participantsTotal ?? 0 > 0 {
            startDatePicker.hidden(true)
            finishDatePicker.hidden(true)
            prizeFundInput.hidden(true)
            prizePlacesInput.hidden(true)
            deleteLabel.hidden(true)
            settingsLabel.hidden(true)
            delayedStartLabel.hidden(true)
            fondAccountDropDownVM.hidden(true)
            balanceAccountLabel.hidden(true)
            photosPanel.hidden(true)
            photosLabel.hidden(true)
            addPhotoButton.hidden(true)
         } else {
            if let finishDate = value.endAt?.dateConvertedToDate1 {
               finishDatePicker.wrappedModel.setState(.currentDate(finishDate))
            }
            if let startDate = value.startAt?.dateConvertedToDate1 {
               delayedStartLabel.setState(.selected(true))
               delayedStartLabel.send(\.didSelected, true)
               startDatePicker.wrappedModel.setState(.currentDate(startDate))
            }
            if let photoUrls = value.photos {
               setState(.setImageURLsToBasket(photoUrls))
            }
         }
         prizeFundInput.wrappedModel.models.main.text(String(value.prizeSize))
         prizePlacesInput.wrappedModel.text(String(value.awardees))

      case let .setFondAccountValues(value):
         let accountNames = value.params.fondAccounts.map {
            switch $0 {
            case let .organization(org):
               let amount = org.amount ?? 0
               return "\(Design.text.organizationAccount), \(Design.text.balance): \(amount)"
            case let .personal(org):
               let amount = org.amount ?? 0
               return "\(Design.text.personalAccount), \(Design.text.balance): \(amount)"
            }
         }

         if accountNames.isNotEmpty {
            switch value.mode {
            case .challengeSettings:
               fondAccountDropDownVM.setStates(
                  .items(accountNames),
                  .selectIndex(value.selectedAccountTypeIndex ?? 0)
               )
            case .templateSettings:
               balanceAccountLabel.hidden(true)
               fondAccountDropDownVM.hidden(true)
            }
         } else {
            balanceAccountLabel.hidden(true)
            fondAccountDropDownVM.hidden(true)
         }

      case let .updateDelayedStart(value):
         if value == true {
            startDatePicker.hidden(false)
         } else {
            startDatePicker.hidden(true)
            startDatePicker.wrappedModel.setState(.titleText(Design.text.challDateOfStart))
         }

      case let .hideBalanceAccount(value):
         fondAccountDropDownVM.hidden(!value)

      case let .imagesToBasket(value):
         photosLabel.hidden(true)
         for image in value {
            scenario2.events.addImageToBasket.sendAsyncEvent(image)
         }

      case let .setImageURLsToBasket(urls):
         let imageURLs = urls.map {
            SpasibkaEndpoints.convertToImageUrl($0)
         }

         imageURLs
            .map {
               PickedImage<Design>(imageUrl: $0)
                  .backColor(Design.color.iconMidpoint)
            }
            .forEach {
               photosPanel.addViewModel($0)
            }

         photosLabel.hidden(true)
         photosPanel.hidden(false)
      }
   }
}

extension ChallengeCreateScene: StateMachine2 {
   func setState2(_ state: SortableImagePickingState) {
      switch state {
      case let .presentImagePickerWithLimit(limit):
         guard let baseVC = vcModel else { return }
         imagePicker
            .setLimit(limit)
            .send(\.presentOn, baseVC)
      case let .presentPickedImage(image):
         let pickedImage = PickedImage<Design>(image: image)
            .backColor(Design.color.iconMidpoint)

         photosPanel.addViewModel(pickedImage)
         setState2(.setHidePanel(false))
      case let .setHideAddPhotoButton(value):
         addPhotoButton.hidden(value)
      case let .setHidePanel(value):
         photosPanel.hidden(value)
      case .presentImagePicker:
         break
      }
   }
}

extension ChallengeCreateScene {
   private func loadImagesFromServer(_ links: [String]) -> [UIImage] {
      var result: [UIImage] = []
      for link in links {
         if let url = URL(string: SpasibkaEndpoints.urlBase + link) {
//            DispatchQueue.global().async {
            let data = try? Data(contentsOf: url)
            if let dateForImage = data, let image = UIImage(data: dateForImage) {
               result.append(image)
            }
//            }
         }
      }
      return result
   }
}
