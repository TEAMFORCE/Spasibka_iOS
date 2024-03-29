//
//  DiagramProfile.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 04.12.2022.
//

import StackNinja
import UIKit

final class MyProfileScene<Asset: ASP>: BaseParamsScene<MyProfileSceneParams<Asset>>, Scenarible2 {
   //
   private(set) lazy var scenario = MyProfileScenario<Asset>(
      works: works,
      stateDelegate: stateDelegate,
      events: MyProfileScenarioInput(
         selectUserStatus: profileVM.newStatusBlcok.on(\.mainStatus),
         selectSecondaryStatus: profileVM.newStatusBlcok.on(\.secondaryStatus),
         settingsDidTap: userSettingsBlock.on(\.didTap),
         didSelectStatus: didSelectStatus,
         didSelectSecondaryStatus: didSelectSecondaryStatus,
         //
         editContactsEvent: editButton.on(\.didTap),
         editLocationEvent: profileVM.eventer.on(\.didTapLocation),
         //
         didContactsChanged: didContactsChanged
      )
   )

   private(set) lazy var scenario2 = AvatarPickingScenario<Asset>(
      works: works,
      stateDelegate: stateDelegate2,
      events: AvatarPickingScenarioEvents(
         startImagePicking: profileVM.avatarTextBlock.avatarButton.on(\.didTap),
         addImageToBasket: imagePicker.on(\.didImagePicked),
         saveCroppedImage: imagePicker.on(\.didImageCropped)
      )
   )

   private lazy var works = MyProfileWorks<Asset>()

   private lazy var profileVM = ProfileVM<Design> {
      $0.avatarTextBlock.hidden(false)
      $0.userBlock.hidden(true)
   }

   private lazy var editButton = Design.button.default
      .title(Design.text.edit)

   private lazy var userSettingsBlock = UserSettingsBlock<Design>()
   private lazy var imagePicker = Design.model.common.imagePicker
      .allowsEditing()

   private let didSelectStatus = Out<UserStatus>()
   private let didSelectSecondaryStatus = Out<UserStatus>()
   private let didContactsChanged = Out<EditContactsInOut.Output>()

   override func start() {
      mainVM.navBar
         .titleLabel.text(Design.text.myProfile)
      mainVM.navBar.menuButton.image(nil)
      
      mainVM.bodyStack
         .padding(.verticalOffset(16))

      mainVM.footerStack
         .arrangedModels(
            editButton.hidden(true)
//            logoutButton
         )

      setState(.initial)

      scenario.configureAndStart()
      scenario2.configureAndStart()
   }
}
enum StatusMode {
   case main
   case secondary
}
enum MyProfileSceneState {
   case initial
   case loaded
   case loadError
   //
   case userAvatar(String)
   case userName(UserNameBlockData)
   case userStatus(String)
   case userSecondaryStatus(String)
   case tagsPercents([UserStat])
   case userLastPeriodRate(LastPeriodRate)
   case userContacts(UserContactData)
   case userWorkPlace(UserWorkData)
   case userRole(UserRoleData)
   //
   case userLocation(UserLocationData)
   //
   case presentUserStatusSelector(StatusMode)
   case presentUserSettings(UserData)
   //
   case presentEditContacts(UserContactData)
   case presentEditLocation(UserData)
}

enum AvatarPickingState {
   case presentImagePicker
   case presentPickedImage(UIImage)
}

extension MyProfileScene: StateMachine2 {
   func setState(_ state: MyProfileSceneState) {
      switch state {
      case .initial:
         mainVM.bodyStack
            .arrangedModels(
               Design.model.common.activityIndicatorSpaced
            )
      case .loaded:
         editButton.hidden(false)
         mainVM.bodyStack
            .arrangedModels(
               Spacer(8),
               profileVM
            )
         profileVM
            .addArrangedModels(
               userSettingsBlock,
               Spacer(48)
            )
//         profileVM.locationBlock
//            .addModel(ImageViewModel()
//               .image(Design.icon.tablerSettings, color: Design.color.iconSecondary)
//               .size(.square(24))) {
//                  $0.fitToTopRight($1, offset: 16, sideOffset: 16)
//            }
         profileVM.userBlock.notifyButton
            .on(\.didTap, self) { _, _ in
               Asset.router?.route(.push, scene: \.notifications)
            }
      case .loadError:
         mainVM.bodyStack
            .arrangedModels(
               Design.model.common.connectionErrorBlock
            )
      //
      case let .userAvatar(avatar):
         profileVM.avatarTextBlock.avatarButton.url(SpasibkaEndpoints.urlBase + avatar, placeHolder: Design.icon.newAvatar)
      case let .userName(name):
         profileVM.userNameBlock.setState(name)
      case let .userStatus(status):
         profileVM.newStatusBlcok.mainStatus.setState(status)
      case let .userSecondaryStatus(status):
         profileVM.newStatusBlcok.secondaryStatus.setState(status)
      case let .tagsPercents(tagsData):
         profileVM.view.layoutIfNeeded()
         profileVM.diagramBlock.setState(tagsData)
      case let .userLastPeriodRate(rate):
         profileVM.userLastRateBlock.setState(rate)
         profileVM.avatarTextBlock.textLabel.text("\(rate.rate)%")
      case let .userContacts(contacts):
         profileVM.userContactsBlock.setState(contacts)
      case let .userWorkPlace(workData):
         profileVM.workingPlaceBlock.setState(workData)
      case let .userRole(roleData):
         profileVM.userRoleBlock.setState(roleData)
      //
      case let .userLocation(locData):
         profileVM.locationBlock.setState(locData)
      //
      case let .presentUserStatusSelector(mode):
         switch mode {
         case .main:
            Asset.router?.route(
               .presentModally(.automatic),
               scene: \.userStatusSelector,
               payload: StatusSelectorInput.mainStatus,
               finishWork: didSelectStatus
            )
         case .secondary:
            Asset.router?.route(
               .presentModally(.automatic),
               scene: \.userStatusSelector,
               payload: StatusSelectorInput.secondaryStatus,
               finishWork: didSelectSecondaryStatus
            )
         }
         

      case let .presentUserSettings(userData):
         Asset.router?.route(.push, scene: \.settings, payload: userData)
      //
      case let .presentEditContacts(contacts):
         Asset.router?.route(
            .push,
            scene: \.editMyContacts,
            payload: contacts,
            finishWork: didContactsChanged
         )
      case .presentEditLocation:
         Asset.router?.route(
            .presentModally(.automatic),
            scene: \.editMyLocation,
            payload: ()
         )
      }
   }

   func setState2(_ state: AvatarPickingState) {
      switch state {
      case .presentImagePicker:
         imagePicker.send(\.presentOn, vcModel)
      case let .presentPickedImage(image):
         profileVM.userBlock.avatarButton.image(image)
         finishSucces(image)
      }
   }
}

struct MyProfileEvents: InitProtocol {
   var didChangeStatus: UserStatus?
}
