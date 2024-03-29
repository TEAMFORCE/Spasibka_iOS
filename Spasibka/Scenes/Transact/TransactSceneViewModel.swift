//
//  TransactModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 29.08.2022.
//

import StackNinja
import UIKit

struct TransactSelectedUser {
   let foundUsed: FoundUser
   let index: Int
   let emptyUsersList: Bool
}

struct TransactEvents: InitProtocol {
   var cancelled: Void?
   var sendButtonPressed: Void?
   var finishWithSuccess: StatusViewInput?
   var finishWithError: Void?
   var setSelectedUserId: Int?
}

enum TransactState {
   case initial
   case error

   case loadTokensSuccess

   case loadBalanceSuccess(Int, Int)

   case loadUsersListSuccess([FoundUser])

   case presentFoundUser([FoundUser])
   case presentUsers([FoundUser])
   case listOfFoundUsers([FoundUser])

   case userSelectedSuccess(FoundUser, Int, Bool)

   case userSearchTFDidEditingChangedSuccess

   case sendCoinSuccess((String, SendCoinRequest, FoundUser))
   case sendCoinError

   case resetCoinInput
   case coinInputSuccess(String, Bool)
   case reasonInputSuccess(String, Bool)

   case presentTagsSelector(Set<Tag>)
   case updateSelectedTags(Set<Tag>, Bool)

   case sendButtonPressed
   case cancelButtonPressed

   case setLoadedSelctableTagsToTagList([SelectWrapper<Tag>])

   case presentStickerSelector
   case setPlaceholdersForStickersCount(Int)
   case addImageToStickerSelector(UIImage, Int)
   case setHideAddStickerButton(Bool)

   case updateReasonFieldText(String)
   case enableAnonymousAvailable(Bool)
}

final class TransactSceneViewModel<Asset: AssetProtocol>: BodyFooterStackModel, Assetable, Scenarible2, Eventable {
   typealias Events = TransactEvents
   typealias State = StackState

   var events: EventsStore = .init()

   private lazy var works = TransactWorks<Asset>()

   lazy var scenario = TransactScenario(
      works: works,
      stateDelegate: stateDelegate,
      events: TransactScenarioEvents(
         userSearchTXTFLDBeginEditing: viewModels.userSearchModel.subModel.models.main.on(\.didBeginEditing),
         userSearchTFDidEditingChanged: viewModels.userSearchModel.subModel.models.main.on(\.didEditingChanged),
         userSelected: viewModels.foundUsersList1.on(\.didSelectItemAtIndex),
         sendButtonEvent: viewModels.sendButton.on(\.didTap),
         amountInputChanged: viewModels.amountInputModel.textField.on(\.didEditingChanged),
         reasonInputChanged: viewModels.reasonTextView.on(\.didEditingChanged),
         anonymousSetOff: viewModels.options.anonimParamModel.switcher.on(\.turnedOff),
         anonymousSetOn: viewModels.options.anonimParamModel.switcher.on(\.turnedOn),
         setTags: viewModels.tagsCloud.on(\.updateTags),
         cancelButtonDidTap: .init(),
         selectedUserId: on(\.setSelectedUserId),
         changePublicMode: viewModels.options.isPublicSwitcher.switcher.on(\.turned),
         // stickers
         addStickerButtonPressed: viewModels.addStickerButton.on(\.didTap),
         didSelectStickerAtIndex: Out<Int>(),
         removeSelectedSticker: viewModels.pickedImages.on(\.didCloseSticker),
         requestPagination: viewModels.foundUsersList1.on(\.requestPagination)
      )
   )

   lazy var scenario2 = ImagePickingScenario<Asset>(
      works: works,
      stateDelegate: stateDelegate2,
      events: ImagePickingScenarioEvents(
         startImagePicking: viewModels.addPhotoButton.on(\.didTap),
         addImageToBasket: imagePicker.on(\.didImagePicked),
         removeImageFromBasket: viewModels.pickedImages.on(\.didCloseImage),
         didMaximumReach: viewModels.pickedImages.on(\.didMaximumImagesReached)
      )
   )

   private lazy var viewModels = TransactViewModels<Design>()

   private lazy var viewModelsWrapper = ScrollStackedModelY()
      .spacing(Grid.x16.value)
      .hideVerticalScrollIndicator()
      .arrangedModels([
//         viewModels.newBalanceInfo,
         viewModels.balanceInfo,
         viewModels.foundUsersList1,
         viewModels.amountInputModel,
         viewModels.tagsCloud,
         viewModels.reasonTextView,
         viewModels.pickedImages.lefted(),
         viewModels.addPhotoButton,
         viewModels.addStickerButton,
         viewModels.options,
         Grid.x48.spacer
      ])

   private lazy var activityIndicator = Design.model.common.activityIndicator
   private lazy var errorInfoBlock = Design.model.common.connectionErrorBlock
   private lazy var imagePicker = Design.model.common.imagePickerExtended

   private lazy var stickerGallery = StickerGalleryVM<Asset>()
      .height(320)
      .on(\.didClose, self) {
         $0.bottomPopupPresenter.setState(.hide)
      }
      .on(\.didSelectStickerIndex, self) {
         $0.viewModels.pickedImages.addSticker($1.0)
         $0.scenario.events.didSelectStickerAtIndex.sendAsyncEvent($1.1)
         $0.bottomPopupPresenter.setState(.hide)
      }

   private lazy var bottomPopupPresenter = BottomPopupPresenter()

   private lazy var darkLoader = DarkLoaderVM<Design>()

   private var currentState = TransactState.initial

   private weak var vcModel: UIViewController?

   convenience init(vcModel: UIViewController?) {
      self.init()

      self.vcModel = vcModel
   }

   private lazy var userAlreadySelected = false

   private var transactSelectedUser: TransactSelectedUser?

   // MARK: - Start

   override func start() {
      super.start()

      configure()
      setToInitialCondition()
      viewModels.foundUsersList1.items([])
      scenario.configureAndStart()
      scenario2.configureAndStart()
      viewModels.userSearchModel.subModel.models.main.view.becomeFirstResponder()
//      viewModels.userSearchTextField.view.becomeFirstResponder()

      padding(.init(top: 0, left: 16, bottom: 16, right: 16))
//      viewModels.foundUsersList1
//         .on(\.didScroll) { [weak self] in
//            print($0.velocity)
//            self?.send(\.didScroll, $0.velocity)
//         }
//         .on(\.willEndDragging) { [weak self] in
//            self?.send(\.willEndDragging, $0.velocity)
//            print($0.velocity)
//         }
//         .activateRefreshControl(color: Design.color.iconBrand)
//         .on(\.refresh, self) {
//            $0.send(\.payload, nil)
//         }
   }

   func configure() {
      //
//      title
//         .set(Design.state.label.semibold16)
//         .text(Design.text.newTransact)
      //
      bodyStack
         .safeAreaOffsetDisabled()
         .axis(.vertical)
         .distribution(.fill)
         .alignment(.fill)
         .arrangedModels([
            //
            viewModels.userSearchModel,
            Grid.x8.spacer,

            viewModels.notFoundBlock.hidden(true),
            errorInfoBlock.hidden(true),
            activityIndicator.hidden(false),

            viewModelsWrapper
         ])
      //
      footerStack
         .arrangedModels([
            Spacer(16),
            viewModels.sendButton
         ])

//      loadTags()
   }

   // MARK: - refact this

   private lazy var useCase = Asset.apiUseCase
   private lazy var storageUseCase = Asset.safeStorageUseCase

   func setSelectedUser(id: Int) {
      send(\.setSelectedUserId, id)
   }
}

extension TransactSceneViewModel: StateMachine2 {
   func setState2(_ state: ImagePickingState) {
      switch state {
      //
      case let .presentPickedImage(image):
         viewModels.pickedImages.addImage(image)
         setState2(.setHidePanel(false))
      //
      case .presentImagePicker:
         break
      //
      case let .setHideAddPhotoButton(value):
         viewModels.addPhotoButton.hidden(value)
      //
      case let .setHidePanel(value):
         viewModels.pickedImages.hidden(value)
      case let .presentImagePickerWithLimit(limit: limit):
         guard let baseVC = vcModel else { return }
         imagePicker
            .setLimit(limit)
            .send(\.presentOn, baseVC)
      }
   }
}

extension TransactSceneViewModel {
   func setState(_ state: TransactState) {
      switch state {
      case .initial:
         activityIndicator.hidden(false)
      //
      case .error:
         activityIndicator.hidden(true)
         presentFoundUsers(users: [])

      //
      case .loadTokensSuccess:
         activityIndicator.hidden(false)

      //
      case let .loadBalanceSuccess(distr, income):
         viewModels.balanceInfo.models.main.setAmount(distr)
         viewModels.balanceInfo.models.right2.setAmount(income)
//         viewModels.balanceInfo.models.main.amount.text(String(distr))
//         viewModels.balanceInfo.models.right2.amount.text(String(income))
//         viewModels.balanceInfo.models.down.label.text(String(income))
//         viewModels.balanceInfo.models.right.label.text(String(distr))
      //
      case let .loadUsersListSuccess(users):
         if !userAlreadySelected {
            presentFoundUsers(users: users)
            activityIndicator.hidden(true)
         }
      //
      //
      case let .presentFoundUser(users):
         viewModels.foundUsersList1.hidden(true)
         activityIndicator.hidden(true)
         presentFoundUsers(users: users)

      //
      case let .presentUsers(users):
         viewModels.foundUsersList1.hidden(true)
         activityIndicator.hidden(true)
         presentFoundUsers(users: users)
      //
      case let .listOfFoundUsers(users):
         activityIndicator.hidden(true)
         presentFoundUsers(users: users)
      //
      case let .userSelectedSuccess(foundUser, index, emptyUsersList):
         userAlreadySelected = emptyUsersList
         viewModels.userSearchModel.hidden(true)

         if case .userSelectedSuccess = currentState {
            UIView.animate(withDuration: 0.3) {
               self.viewModels.userSearchModel.hidden(false)
               self.viewModels.foundUsersList1.hidden(true)
               self.currentState = .initial
            }
            self.applySelectUserMode()
            let text = viewModels.userSearchModel.subModel.models.main.view.text
            viewModels.userSearchModel.subModel.models.main.send(\.didEditingChanged, text.string)
            userAlreadySelected = true
            return
         }

         currentState = state
         transactSelectedUser = TransactSelectedUser(foundUsed: foundUser, index: index, emptyUsersList: emptyUsersList)
         presentTransactWithSelectedUser(foundUser: foundUser, index: index, emptyUsersList: emptyUsersList)
      //
      case .userSearchTFDidEditingChangedSuccess:
         activityIndicator.hidden(false)
         viewModels.foundUsersList1.items([])
         applySelectUserMode()
      //
      case let .sendCoinSuccess(tuple):
         darkLoader.setState(.hide)
         let sended = StatusViewInput(
            sendCoinInfo: tuple.1,
            username: tuple.0,
            foundUser: tuple.2
         )
//         send(\.finishWithSuccess, sended)

         setToInitialCondition()
         let ticketView = CustomTicketView<Design>()
         let name = sended.foundUser.name.unwrap + " " + sended.foundUser.surname.unwrap
         let firstnameLetter = sended.foundUser.name?.first?.toString ?? ""
         let surnameLetter = sended.foundUser.surname?.first?.toString ?? ""
         let imageText = firstnameLetter + surnameLetter

         var imageUrl: String? = nil
         if let url = sended.foundUser.photo, !url.isEmpty {
            imageUrl = SpasibkaEndpoints.urlBase + url
         }
         
         ticketView.setUserInfo(name: name, image: nil, imageUrl: imageUrl, textImage: imageText)
         ticketView.setCount(sended.sendCoinInfo.amount.toInt ?? 0)
         ticketView.setState(.inProcess)
         ticketView.setDate(date: .init())

//         view.addSubview(ticketView)
         if let superview = superview?.superview {
            superview.addSubview(ticketView)
            NSLayoutConstraint.activate([
               ticketView.topAnchor.constraint(equalTo: superview.topAnchor),
               ticketView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
               ticketView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
               ticketView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
            ticketView.show()
         }
         applySelectUserMode()
         
      //
      case .sendCoinError:
         darkLoader.setState(.hide)
         send(\.finishWithError)
      case .resetCoinInput:
         viewModels.amountInputModel.setState(.noInput)
      case let .coinInputSuccess(text, isCorrect):
         viewModels.amountInputModel.textField.set(.text(text))
         if isCorrect {
            viewModels.amountInputModel.setState(.normal(text))
            viewModels.sendButton.set(Design.state.button.default)
         } else {
            viewModels.amountInputModel.textField.set(.text(text))
            viewModels.sendButton.set(Design.state.button.inactive)
         }
      //
      case let .reasonInputSuccess(text, isCorrect):
         viewModels.reasonTextView.set(.text(text))
         if isCorrect {
            viewModels.sendButton.set(Design.state.button.default)
         } else {
            viewModels.reasonTextView.set(.text(text))
            viewModels.sendButton.set(Design.state.button.inactive)
         }

      case .sendButtonPressed:
         darkLoader.setState(.loading(onView: vcModel?.view.rootSuperview))

      //
      case .cancelButtonPressed:
         if userAlreadySelected == true, let value = transactSelectedUser {
            setState(.userSelectedSuccess(
               value.foundUsed,
               value.index,
               value.emptyUsersList
            ))
         } else {
            send(\.cancelled)
         }
      //

      case .presentTagsSelector:
         break
      //
      case let .updateSelectedTags(_, isCorrect):
         if isCorrect {
            viewModels.sendButton.set(Design.state.button.default)
         } else {
            viewModels.sendButton.set(Design.state.button.inactive)
         }

      case let .setLoadedSelctableTagsToTagList(tags):
         view.layoutIfNeeded()
         viewModels.tagsCloud.setState(tags)

      case .presentStickerSelector:
         bottomPopupPresenter.setState(.presentWithAutoHeight(model: stickerGallery, onView: view.superview))

      case let .setPlaceholdersForStickersCount(count):
         stickerGallery.setState(.setPlaceholdersForStickersCount(count))

      case let .addImageToStickerSelector(image, index):
         stickerGallery.setState(.addStickerImage(image, index))

      case let .setHideAddStickerButton(value):
         viewModels.addStickerButton.hidden(value)

      case let .updateReasonFieldText(text):
         viewModels.reasonTextView.text(text)
      case let .enableAnonymousAvailable(value):
         if value == false {
            viewModels.options.anonimParamModel.hidden(true)
         }
      }
   }
}

private extension TransactSceneViewModel {
   private func setToInitialCondition() {
      clearFields()

      viewModels.sendButton.set(Design.state.button.inactive)
      viewModels.amountInputModel.setState(.noInput)

      currentState = .initial
      setState(.initial)
      applySelectUserMode()
   }

   private func clearFields() {
      viewModels.userSearchModel.subModel.models.main.text("")
      viewModels.amountInputModel.textField.text("")
      viewModels.reasonTextView
         .text("")
         .placeholder(Design.text.reasonPlaceholder)
      viewModels.pickedImages.clear()
   }

   func applySelectUserMode() {
      footerStack.hidden(true)
      viewModels.options.hidden(true)
      viewModels.addPhotoButton.hidden(true)
      viewModels.addStickerButton.hidden(true)
      viewModels.pickedImages.hidden(true)
      viewModels.reasonTextView.hidden(true)
      viewModels.amountInputModel.set(.hidden(true))
      viewModels.userSearchModel.hidden(false)
      viewModels.balanceInfo.set(.hidden(true))
      viewModels.tagsCloud.set(.hidden(true))

      viewModels.notFoundBlock.hidden(true)
   }

   func presentBalanceInfo() {
      viewModels.notFoundBlock.hidden(true, isAnimated: true)
      viewModels.balanceInfo.set(.hidden(false, isAnimated: true))
   }

   func applyReadyToSendMode() {
      viewModels.amountInputModel.hidden(false, isAnimated: true)
      viewModels.reasonTextView.hidden(false, isAnimated: true)
      viewModels.pickedImages.hidden(false, isAnimated: true)
      viewModels.addPhotoButton.hidden(false, isAnimated: true)
      viewModels.addStickerButton.hidden(false, isAnimated: true)
      viewModels.options.hidden(false, isAnimated: true)
      viewModels.tagsCloud.hidden(false, isAnimated: true)
      footerStack.hidden(false, isAnimated: true)
      viewModels.userSearchModel.hidden(true, isAnimated: true)
      view.endEditing(true)
   }

   func presentTransactWithSelectedUser(foundUser: FoundUser, index _: Int, emptyUsersList: Bool) {
      viewModelsWrapper.set(.scrollToTopAnimated(true))
      presentBalanceInfo()

      UIView.animate(withDuration: 0.1) {
         if emptyUsersList == true {
            self.activityIndicator.hidden(true)
            self.presentFoundUsers(users: [foundUser])
         }
         // self.viewModels.foundUsersList.set(.removeAllExceptIndex(index))
         self.viewModels.foundUsersList1.items([foundUser])
         self.view.layoutIfNeeded()
      } completion: { _ in
         self.applyReadyToSendMode()
      }
   }
}

private extension TransactSceneViewModel {
   func presentFoundUsers(users: [FoundUser]) {
      viewModels.foundUsersList1.items(users)
      viewModels.foundUsersList1.hiddenAnimated(users.isEmpty ? true : false, duration: 0.5)

      viewModels.notFoundBlock.hiddenAnimated(!users.isEmpty, duration: 0.5)
   }
}
