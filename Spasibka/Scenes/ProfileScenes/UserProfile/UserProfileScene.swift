//
//  ProfileScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 16.11.2022.
//

import UIKit
import StackNinja

struct ProfileSceneParams<Asset: AssetProtocol>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = BrandTripleStackVM<Asset.Design>
   }
   
   struct InOut: InOutParams {
      typealias Input = ProfileID
      typealias Output = Void
   }
}

final class UserProfileScene<Asset: ASP>: BaseParamsScene<ProfileSceneParams<Asset>> {
   lazy var scenario = UserProfileScenario<Asset>(
      works: UserProfileWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: UserProfileScenarioInput(
         loadProfileById: on(\.input),
         thankButtonTapped: thankButton.on(\.didTap)
      )
   )

   private lazy var profileVM = ProfileVM<Design>()
   private lazy var thankButton = Design.button.default
      .set(Design.state.button.default)
      .title(Design.text.thankButton)
   
   private lazy var transactModel: TransactSceneViewModel = TransactSceneViewModel<Asset>(vcModel: vcModel)
 
   lazy var bottomPopupPresenter = BottomPopupPresenter()

   override func start() {
      vcModel?
         .title(Design.text.profile)

      mainVM.bodyStack
         .padding(.verticalOffset(16))

      setState(.initial)

      scenario.configureAndStart()
   }
}

extension UserProfileScene: TransactPopupPresenterProtocol {}

enum UserProfileSceneState {
   case initial
   case loaded
   case loadError
   //
   case userAvatar(String) // needs to combine to one i think ))
   case userName(UserNameBlockData) // needs to combine to one i think ))
   case userStatus(String) // needs to combine to one i think ))
   case userSecondaryStatus(String)
   case tagsPercents([UserStat]) // needs to combine to one i think ))
   case userContacts(UserContactData) // needs to combine to one i think ))
   case userWorkPlace(UserWorkData) // needs to combine to one i think ))
   case userRole(UserRoleData) // needs to combine to one i think ))
   //
   case userLocation(UserLocationData)
   
   case presentTransactScene(Int)
}

extension UserProfileScene: StateMachine {
   func setState(_ state: UserProfileSceneState) {
      switch state {
      case .initial:
         mainVM.bodyStack
            .arrangedModels(
               Design.model.common.activityIndicatorSpaced
            )
      case .loaded:
         mainVM.bodyStack
            .arrangedModels(
               profileVM,
               Spacer()
            )
         mainVM.footerStack
            .arrangedModels(thankButton)
         profileVM
            .addArrangedModels(
               Spacer(48)
            )
//            .userStatusBlock.chevronIcon.hidden(true)
            .newStatusBlcok.mainStatus.chevronIcon.hidden(true)
         
         profileVM
            .newStatusBlcok.secondaryStatus.chevronIcon.hidden(true)
         
         profileVM.userBlock.notifyButton
            .on(\.didTap, self) { _,_ in
               Asset.router?.route(.push, scene: \.notifications)
            }
      case .loadError:
         mainVM.bodyStack
            .arrangedModels(
               Design.model.common.connectionErrorBlock
            )
      //
      case let .userAvatar(avatar):
         profileVM.userBlock.avatarButton.url(SpasibkaEndpoints.urlBase + avatar, placeHolder: Design.icon.newAvatar)
         profileVM.userBlock.avatarButton.view
            .startTapGestureRecognize()
            .on(\.didTap, self) { _,_ in
               let fullUrl = SpasibkaEndpoints.convertToFullImageUrl(avatar)
               Asset.router?.route(.presentModally(.automatic), scene: \.imageViewer, payload: ImageViewerInput.url(fullUrl))
            }
      case let .userName(name):
         profileVM.userNameBlock.setState(name)
      case let .userStatus(status):
//         profileVM.userStatusBlock.setState(status)
         profileVM.newStatusBlcok.mainStatus.setState(status)
      case let .userSecondaryStatus(status):
         profileVM.newStatusBlcok.secondaryStatus.setState(status)
      case let .tagsPercents(tagsData):
         profileVM.view.layoutIfNeeded()
         profileVM.diagramBlock.setState(tagsData)
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
      case let .presentTransactScene(id):
         var input = TransactSceneInput.byId(id)
         Asset.router?.route(.push,
                             scene: \.transactions,
                             payload: input)
      }
   }
}

final class SettingsTitleBodyDT<Design: DSP>: TitleSubtitleY<Design> {
   required init() {
      super.init()
      spacing(4)
      setAll { main, down in
         main
            .alignment(.left)
            .set(Design.state.label.regular12)
            .textColor(Design.color.textSecondary)
         down
            .alignment(.left)
            .set(Design.state.label.regular14)
            .textColor(Design.color.text)
      }
   }
}

final class UserProfileStack<Design: DSP>: StackModel, Designable {
   override func start() {
      super.start()

      backColor(Design.color.backgroundInfoSecondary)
      padding(.init(top: 16, left: 16, bottom: 16, right: 16))
      cornerRadius(Design.params.cornerRadiusSmall)
      cornerCurve(.continuous)
      spacing(12)
      distribution(.equalSpacing)
      alignment(.leading)
   }
}

final class ProfileTitle<Design: DSP>: StackModel, Designable {
   override func start() {
      axis(.horizontal)
      spacing(8)
      arrangedModels(
         LabelModel()
            .set(Design.state.label.medium20invert)
            .text(Design.text.profile)
            .textColor(Design.color.textInvert),
         ImageViewModel()
            .size(.square(24))
            .image(Design.icon.tablerChevronDown)
            .imageTintColor(Design.color.iconInvert)
      )
   }
}
