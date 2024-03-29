//
//  BalanceViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.07.2022.
//

import CoreFoundation
import StackNinja
import UIKit

struct BalanceSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class BalanceScene<Asset: AssetProtocol>: BaseParamsScene<BalanceSceneParams<Asset>>, Scenarible {

   lazy var scenario = BalanceScenario(
      works: BalanceWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: BalanceScenarioInputEvents(
         didTapNewTransactSegment: newTransactSegment.on(\.didTapButtonIndex),
         didSelectHistoryItem: tableModel.on(\.didSelectRow),
         presentHistoryScene: allHistoryLabel.on(\.didTap),
         reloadNewNotifies: Work.void
      )
   )


   // MARK: - Frame Cells

   private lazy var selectPeriod = LabelIconX<Design>(Design.state.stack.buttonFrame)
      .set {
         $0.label
            .text(Design.text.selectPeriod)
            .textColor(Design.color.textSecondary)
         $0.iconModel
            .image(Design.icon.calendarLine)
            .imageTintColor(Design.color.iconBrand)
      }

   private lazy var balanceFrames = FramesViewModel<Design>()


   private lazy var newTransactSegment = ScrollableSegmentControl<Design>()
      .clipsToBound(false)

   private lazy var newTransactLabel = Design.label.descriptionMedium14
      .text(Design.text.transferVerb)
   
   private let historyOfTransactionsLabel = Design.label.descriptionMedium14
      .text(Design.text.historyOfTransactions)
   
   private let allHistoryLabel = Design.label.descriptionMedium14
      .text(Design.text.all1)
      .textColor(Design.color.textInfo)
      .makeTappable()
   
   private lazy var historyLabelsStack = StackModel()
      .axis(.horizontal)
      .alignment(.leading)
      .distribution(.fill)
      .arrangedModels([
         historyOfTransactionsLabel,
         Grid.xxx.spacer,
         allHistoryLabel
      ])
      

   private lazy var transactModel: TransactScene = TransactScene<Asset>()//(vcModel: vcModel)
   lazy var bottomPopupPresenter = BottomPopupPresenter()
   
   private let backColor = UIColor(red: 0.542, green: 0.542, blue: 0.542, alpha: 0)
   private let presenter = HistoryPresenters<Design>()
   private lazy var tableModel = TableItemsModel()
      .presenters(
         presenter.transactToHistoryCell
      )
      .backColor(Design.color.background)
      .headerParams(labelState: Design.state.label.labelRegularContrastColor14, backColor: backColor)
      .footerModel(Spacer(96))
      .setNeedsLayoutWhenContentChanged()
   
   private lazy var profileButton: ProfileButtonModel = ProfileButtonModel<Design>()
   .setStates(
      .text(Design.text.hello),
      .image(Design.icon.avatarPlaceholder.insetted(14))
   )
   
//   private let updateMyProfileFinishWork = Out<UIImage>()

   lazy var notificationBell = NotificationBellViewModel()
   
   private lazy var topButtonsStack = StackModel()
      .axis(.horizontal)
      .spacing(Grid.x8.value)
      .arrangedModels([
         Spacer(16),
         profileButton,
         Grid.xxx.spacer,
//         notifyButton,
         notificationBell,
         Spacer(16)
      ])
      .height(60)
   
   
   private lazy var wrappedTableModel = WrappedX(tableModel)
   private lazy var scrollWrapper = ScrollStackedModelY()
      .set(.arrangedModels([
//         profileButton,
//         topButtonsStack,
         balanceFrames,
         Spacer(20),
         newTransactLabel,
         Spacer(12),
         newTransactSegment,
         Spacer(12),
         historyLabelsStack,
         Spacer(12),
         wrappedTableModel.padding(.horizontalOffset(-16)),
         activityIndicator,
         Grid.xxx.spacer,
      ]))
      .padding(.horizontalOffset(16))
      .hideVerticalScrollIndicator()

   private lazy var errorBlock = Design.model.common.connectionErrorBlock
   private lazy var activityIndicator = Design.model.common.activityIndicatorSpaced

   // MARK: - Services

   private var balance: Balance?

   override func start() {
      notificationBell.setBlackIcon()
      balanceFrames.start()
      
      mainVM.navBar.hidden(true)
      mainVM.bodyStack
         .distribution(.fill)
         .alignment(.fill)
         .arrangedModels([
            Spacer(8),
            topButtonsStack,//.padHorizontal(16),
            scrollWrapper,
         ])
   
      mainVM.bodyStack.addModel(errorBlock, setup: {
         $0.fitToTop($1)
      })
//      scrollWrapper
//         .on(\.didScroll) { [weak self] in
//            self?.send(\.didScroll, $0.velocity)
//         }
//         .on(\.willEndDragging) { [weak self] in
//            self?.send(\.willEndDragging, $0.velocity)
//         }
      scrollWrapper.view.alwaysBounceVertical = true

      profileButton.on(\.didTap) {
         Asset.router?.route(.push, scene: \.myProfile)
      }
      
      notificationBell.on(\.didTap) {
         Asset.router?.route(.push, scene: \.notifications)
      }
      
      vcModel?.on(\.viewWillAppear, self) {
         $0.scenario.events.reloadNewNotifies.doAsync()
      }
      
      scenario.configureAndStart()
      setState(.initial)
   }
}

enum BalanceSceneState {
   case initial
   case balanceDidLoad(Balance)
   case loadBalanceError
   case setTransactInfo([TransactButtonInfo])
   case presentTransactScene(Int?)
   case presentTransactions([TableItemsSection])
   case presentHistoryDetailView(Transaction)
   case presentHistoryScene(UserData)
   case setUserProfileInfo(String, String?)
   case updateAlarmButtonWithNewNotificationsCount(Int)
}

extension BalanceScene: StateMachine {
   func setState(_ state: BalanceSceneState) {
      switch state {
      case .initial:
         scrollWrapper.alpha(0.42)
         errorBlock.hidden(true)
         activityIndicator.hidden(false)
      case let .balanceDidLoad(balance):
         scrollWrapper.alpha(1)
         errorBlock.hidden(true)
         activityIndicator.hidden(true)
         balanceFrames.setState(.setBalance(balance))
      case .loadBalanceError:
         scrollWrapper.alpha(0.42)
         errorBlock.hidden(false)
         activityIndicator.hidden(true)
      case let .setTransactInfo(value):
         var buttons: [TransactButtonModel<Design>] = []
         let newTransactButton = TransactButtonModel<Design>()
            .setStates(
               .text(Design.text.new),
               .image(Design.icon.tablerPlus.insetted(14))
            )
         newTransactButton.models.main.backColor(Design.color.iconBrand)
         newTransactButton.models.main.imageTintColor(.white)
         buttons.append(newTransactButton)
         for user in value {
            let button = TransactButtonModel<Design>()
               .setStates(.text(user.username))
            if let url = user.photo {
               button.setState(.imageUrl(SpasibkaEndpoints.urlBase + url))
            }
            buttons.append(button)
         }
         newTransactSegment.setState(.buttons(buttons))
         newTransactSegment.set(.padding(.zero))
         newTransactSegment.set(.spacing(16))
      case let .presentTransactScene(id):
         var input = TransactSceneInput.normal
         if let id = id {
            input = TransactSceneInput.byId(id)
         }
         Asset.router?.route(.push,
                             scene: \.transactions,
                             payload: input)
         
      case let .presentTransactions(value):
         tableModel
            .itemSections(value)
      case let .presentHistoryDetailView(value):
         Asset.router?.route(.presentModally(.automatic),
                             scene: \.sentTransactDetails,
                             payload: value)
      case let .presentHistoryScene(currentUser):
         Asset.router?.route(.push,
                             scene: \.history,
                             payload: currentUser)
      case let .setUserProfileInfo(name, imageUrl):
         profileButton.setName(name: name)
//         profileButton.setState(.text(Design.text.hello + "\n\(name)"))
         if let url = imageUrl {
            profileButton.setState(.imageUrl(SpasibkaEndpoints.urlBase + url))
         }
      case let .updateAlarmButtonWithNewNotificationsCount(count):
         notificationBell.setNotificationsCount(count)
      }
   }
}

extension BalanceScene: TransactPopupPresenterProtocol {}

extension Calendar {
   func numberOf24DaysBetween(_ from: Date, and to: Date) -> Int {
      let numberOfDays = dateComponents([.day], from: from, to: to)

      return numberOfDays.day! + 1
   }
}
