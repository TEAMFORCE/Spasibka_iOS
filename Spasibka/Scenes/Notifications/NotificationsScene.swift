//
//  NotificationsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.11.2022.
//

import Foundation
import StackNinja

struct NotificationsSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class NotificationsScene<Asset: ASP>: BaseParamsScene<NotificationsSceneParams<Asset>>,
   Scenarible2
{
   private lazy var works = NotificationsWorks<Asset>()

   lazy var scenario = NotificationsScenario(
      works: works,
      stateDelegate: stateDelegate,
      events: NotificationsEvents(
         requestPagination: notifyViewModel.tableModel.on(\.requestPagination)
      )
   )

   lazy var scenario2 = NotificationsDetailsScenario(
      works: works,
      stateDelegate: feedDetailsRouter.stateDelegate,
      events: NotificationsDetailsEvents(
         didSelectIndex: notifyViewModel.on(\.didSelectRow)
      )
   )

   private lazy var notifyViewModel = NotificationsViewModel<Design>().hidden(true)
   private lazy var activityIndicatorSpaced = Design.model.common.activityIndicator
   private lazy var hereIsEmpty = Design.model.common.hereIsEmpty.hidden(true)
   private lazy var connectionErrorBlock = Design.model.common.connectionErrorBlock.hidden(true)

   // Details Presenter
   private lazy var feedDetailsRouter = FeedDetailsRouter<Asset>()

   override func start() {
      super.start()

      setState(.initial)

      scenario.configureAndStart()
      scenario2.configureAndStart()
      mainVM.navBar.menuButton.image(nil)
   }
}

enum NotificationsState {
   case initial
   case presentNotifySections([TableItemsSection])
   case hereIsEmpty
   case loadNotifyError
   case presentActivityIndicator
   case hideActivityIndicator
   case updateUnreadAmount(Int)
}

extension NotificationsScene: StateMachine {
   func setState(_ state: NotificationsState) {
      switch state {
      case .initial:
         mainVM.navBar
            .titleLabel.text(Design.text.notifications)
//         mainVM.headerStack.arrangedModels(Spacer(8))
         mainVM.bodyStack.arrangedModels(
            hereIsEmpty,
            connectionErrorBlock,
            notifyViewModel,
            activityIndicatorSpaced,
            Spacer()
         )
      case let .presentNotifySections(notifications):
         activityIndicatorSpaced.hidden(true)
         connectionErrorBlock.hidden(true)
         notifyViewModel.hidden(false)
         hereIsEmpty.hidden(true)
         notifyViewModel.tableModel
            .presenters(
               notifyViewModel.presenter.notifyCell,
               SpacerPresenter.presenter
            )
         notifyViewModel.setState(.tableData(notifications))
      case .presentActivityIndicator:
         hereIsEmpty.hidden(true)
         activityIndicatorSpaced.hidden(false)
         connectionErrorBlock.hidden(true)
      case .hideActivityIndicator:
         activityIndicatorSpaced.hidden(true)
      case .hereIsEmpty:
         notifyViewModel.hidden(true)
         hereIsEmpty.hidden(false)
         activityIndicatorSpaced.hidden(true)
         connectionErrorBlock.hidden(true)
      case .loadNotifyError:
         notifyViewModel.hidden(true)
         hereIsEmpty.hidden(true)
         activityIndicatorSpaced.hidden(true)
         connectionErrorBlock.hidden(false)
      case let .updateUnreadAmount(amount):
         notifyViewModel.setStates(.setUnreadNotificationsAmount(amount))
      }
   }
}
