//
//  StatusSelectorScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja

enum StatusSelectorInput {
   case mainStatus
   case secondaryStatus
}

final class StatusSelectorScene<Asset: ASP>: BaseSceneModel<
   DefaultVCModel,
   ModalDoubleStackModel<Asset>,
   Asset,
   StatusSelectorInput,
   UserStatus
>, Scenarible {
   //
   private lazy var statusTable = TableItemsModel()
      .backColor(Design.color.background)
      .separatorStyle(.singleLine)
      .separatorColor(Design.color.iconMidpoint)
      .presenters(UserStatusPresenter<Design>.cellPresenter)

   lazy var scenario = StatusSelectorScenario(
      works: StatusSelectorWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: StatusSelectorInputEvents(
         saveInput: on(\.input),
         didSelectStatus: statusTable.on(\.didSelectItemAtIndex)
      )
   )

   override func start() {
      mainVM.title.text(Design.text.status)
      mainVM.closeButton.on(\.didTap, self) {
         $0.dismiss()
      }
      setState(.initial)
      scenario.configureAndStart()
   }
}

enum StatusSelectorState {
   case initial
   case setTitle(StatusSelectorInput)
   case presentStatusList([UserStatus])
   case selectStatusAndDismiss(UserStatus)
}

extension StatusSelectorScene: StateMachine {
   func setState(_ state: StatusSelectorState) {
      switch state {
      case .initial:
         mainVM.bodyStack.arrangedModels(
            Design.model.common.activityIndicatorSpaced
         )
      case let .setTitle(input):
         if input == .mainStatus {
            mainVM.title.text(Design.text.status)
         } else {
            mainVM.title.text(Design.text.workFormat)
         }
      case .presentStatusList(let list):
         mainVM.bodyStack.arrangedModels(
            statusTable
         )
         statusTable.items(list)
      case .selectStatusAndDismiss(let status):
         finishSucces(status)
         dismiss()
      }
   }
}

struct UserStatusPresenter<Design: DSP> {
   static var cellPresenter: CellPresenterWork<UserStatus, UserStatusCell<Design>> {
      CellPresenterWork { work in
         let status = work.unsafeInput.item

         let cell = UserStatusCell<Design>()
         cell.icon.image(UserStatusFabric<Design>.icon(status))
         let text = getStatusText(value: status)
         cell.label.text(text)
         

         work.success(cell)
      }
   }
   
   static func getStatusText(value: UserStatus?) -> String {
      var res = ""
      switch value {
      case .vacation:
         res = Design.text.vactionStatus
      case .working:
         res = Design.text.workingStatus
      case .sickLeave:
         res = Design.text.sickLeaveStatus
      case .remote:
         res = Design.text.remoteStatus
      case .office:
         res = Design.text.inOfficeStatus
      case .none:
         res = Design.text.notIndicated
      }
      return res
   }
}

final class UserStatusCell<Design: DSP>: Stack<WrappedX<ImageViewModel>>.R<LabelModel>.R2<Spacer>.Ninja {
   var icon: ImageViewModel { models.main.subModel }
   var label: LabelModel { models.right }

   required init() {
      super.init(isAutoreleaseView: true)

      setAll { iconWrapper, text, _ in
         iconWrapper
            .size(.square(50))
            .backColor(Design.color.backgroundInfoSecondary)
            .cornerCurve(.continuous).cornerRadius(50 / 2)
            .alignment(.center)
         iconWrapper.subModel
            .size(.square(24))
         text
            .set(Design.state.label.regular16)
      }
      spacing(16)
      padding(.init(top: 10, left: 0, bottom: 10, right: 0))
   }
}

import UIKit

struct UserStatusFabric<Design: DSP> {

   static func icon(_ status: UserStatus) -> UIImage {
      switch status {
      case .office:
         return Design.icon.tablerBuildingArch
      case .vacation:
         return Design.icon.tablerDevicesPc
      case .remote:
         return Design.icon.tablerAerialLift
      case .sickLeave:
         return Design.icon.tablerHeartbeat
      case .working:
         return Design.icon.tablerBuildingArch
      }
   }
}
