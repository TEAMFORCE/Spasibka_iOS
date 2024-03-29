////
////  BalanceSceneViewModel.swift
////  Spasibka
////
////  Created by Aleksandr Solovyev on 07.02.2024.
////
//
//import StackNinja
//import UIKit
//
//final class BalanceSceneViewModel<Asset: ASP>: VStackModel, Scenarible, Assetable, Eventable {
//   typealias Events = MainSceneEvents<UserData?>
//
//   lazy var scenario = BalanceScenario(
//      works: BalanceWorks<Asset>(),
//      stateDelegate: stateDelegate,
//      events: BalanceScenarioInputEvents(
//         didTapNewTransactSegment: newTransactSegment.on(\.didTapButtonIndex),
//         didSelectHistoryItem: tableModel.on(\.didSelectRow),
//         presentHistoryScene: allHistoryLabel.on(\.didTap),
//         reloadNewNotifies: Work.void
//      )
//   )
//
//   var events = EventsStore()
//
//   // MARK: - Frame Cells
//
//   private lazy var selectPeriod = LabelIconX<Design>(Design.state.stack.buttonFrame)
//      .set {
//         $0.label
//            .text(Design.text.selectPeriod)
//            .textColor(Design.color.textSecondary)
//         $0.iconModel
//            .image(Design.icon.calendarLine)
//            .imageTintColor(Design.color.iconBrand)
//      }
//
//   private lazy var balanceFrames = FramesViewModel<Design>()
//
//   private lazy var annulationFrame = BalanceStatusFrameDT<Design>()
//      .setMain {
//         $0
//            .image(Design.icon.cross)
//            .imageTintColor(Design.color.textError)
//      } setRight: {
//         $0
//            .text(Design.text.cancelled)
//            .textColor(Design.color.textError)
//      } setDown: {
//         $0
//            .padTop(6)
//            .text("0")
//      }
//      .backColor(Design.color.errorSecondary)
//
//   private lazy var inProgessFrame = BalanceStatusFrameDT<Design>()
//      .setMain {
//         $0
//            .image(Design.icon.inProgress)
//            .imageTintColor(Design.color.success)
//      } setRight: {
//         $0
//            .text(Design.text.onAgreement)
//            .textColor(Design.color.success)
//      } setDown: {
//         $0
//            .padTop(6)
//            .text("0")
//      }
//      .backColor(Design.color.successSecondary)
//      .hidden(true)
//
//   private lazy var newTransactSegment = ScrollableSegmentControl<Design>()
//
//   private lazy var newTransactLabel = Design.label.descriptionMedium14
//      .text(Design.text.transferVerb)
//
//   private let historyOfTransactionsLabel = Design.label.descriptionMedium14
//      .text(Design.text.historyOfTransactions)
//
//   private let allHistoryLabel = Design.label.descriptionMedium14
//      .text(Design.text.all1)
//      .textColor(Design.color.textInfo)
//      .makeTappable()
//
//   private lazy var historyLabelsStack = StackModel()
//      .axis(.horizontal)
//      .alignment(.leading)
//      .distribution(.fill)
//      .arrangedModels([
//         historyOfTransactionsLabel,
//         Grid.xxx.spacer,
//         allHistoryLabel
//      ])
//
//   private let backColor = UIColor(red: 0.542, green: 0.542, blue: 0.542, alpha: 0)
//   private let presenter = HistoryPresenters<Design>()
//   private lazy var tableModel = TableItemsModel()
//      .presenters(
//         presenter.transactToHistoryCell
//      )
//      .backColor(Design.color.background)
//      .headerParams(labelState: Design.state.label.labelRegularContrastColor14, backColor: backColor)
//      .footerModel(Spacer(96))
//      .setNeedsLayoutWhenContentChanged()
//
//   private lazy var profileButton: ProfileButtonModel = ProfileButtonModel<Design>()
//      .setStates(
//         .text(Design.text.new),
//         .image(Design.icon.avatarPlaceholder.insetted(14))
//      )
//
//   lazy var notifyButton = ButtonModel()
//      .set(Design.state.button.transparent)
//      .size(.square(Grid.x36.value))
//      .image(Design.icon.newAlarm, color: Design.color.iconContrast)
//
//   private lazy var topButtonsStack = StackModel()
//      .axis(.horizontal)
//      .spacing(8)
//      .arrangedModels(
//         profileButton,
//         Grid.xxx.spacer,
//         notifyButton
//      )
//      .height(60)
//      .padHorizontal(16)
//      .padTop(-24)
//
//   private lazy var wrappedTableModel = WrappedX(tableModel)
//   private lazy var scrollWrapper = ScrollStackedModelY()
//      .set(.arrangedModels([
//         balanceFrames,
//         Spacer(20),
//         newTransactLabel,
//         Spacer(12),
//         newTransactSegment,
//         Spacer(12),
//         historyLabelsStack,
//         Spacer(12),
//         wrappedTableModel.padding(.horizontalOffset(-16)),
//         activityIndicator,
//         Grid.xxx.spacer
//      ]))
//      .padding(.horizontalOffset(16))
//
//   private lazy var errorBlock = Design.model.common.connectionErrorBlock
//   private lazy var activityIndicator = Design.model.common.activityIndicatorSpaced
//
//   // MARK: - Services
//
//   private var balance: Balance?
//
//   override func start() {
//      balanceFrames.start()
//      arrangedModels(
//         topButtonsStack,
//         scrollWrapper
//      )
//      addModel(errorBlock, setup: {
//         $0.fitToTop($1)
//      })
//
//      profileButton.on(\.didTap) {
//         Asset.router?.route(.push, scene: \.myProfile)
//      }
//
//      notifyButton.on(\.didTap) {
//         Asset.router?.route(.push, scene: \.notifications)
//      }
//
//      scenario.events.reloadNewNotifies.doAsync()
//
//      setState(.initial)
//   }
//}
//
//enum BalanceSceneState {
//   case initial
//   case balanceDidLoad(Balance)
//   case loadBalanceError
//   case setTransactInfo([TransactButtonInfo])
//   case presentTransactScene(Int?)
//   case presentTransactions([TableItemsSection])
//   case presentHistoryDetailView(Transaction)
//   case presentHistoryScene(UserData)
//   case setUserProfileInfo(String, String?)
//   case updateAlarmButtonWithNewNotificationsCount(Int)
//}
//
//extension BalanceSceneViewModel: StateMachine {
//   func setState(_ state: BalanceSceneState) {
//      switch state {
//      case .initial:
//         scrollWrapper.alpha(0.42)
//         errorBlock.hidden(true)
//         activityIndicator.hidden(false)
//      case let .balanceDidLoad(balance):
//         scrollWrapper.alpha(1)
//         errorBlock.hidden(true)
//         activityIndicator.hidden(true)
//         balanceFrames.setState(.setBalance(balance))
//      case .loadBalanceError:
//         scrollWrapper.alpha(0.42)
//         errorBlock.hidden(false)
//         activityIndicator.hidden(true)
//      case let .setTransactInfo(value):
//         var buttons: [TransactButtonModel<Design>] = []
//         let newTransactButton = TransactButtonModel<Design>()
//            .setStates(
//               .text(Design.text.new),
//               .image(Design.icon.tablerPlus.insetted(14))
//            )
//         newTransactButton.models.main.backColor(Design.color.iconBrand)
//         newTransactButton.models.main.imageTintColor(.white)
//         buttons.append(newTransactButton)
//         for user in value {
//            let button = TransactButtonModel<Design>()
//               .setStates(.text(user.username))
//            if let url = user.photo {
//               button.setState(.imageUrl(SpasibkaEndpoints.urlBase + url))
//            }
//            buttons.append(button)
//         }
//         newTransactSegment.setState(.buttons(buttons))
//         newTransactSegment.set(.padding(.zero))
//         newTransactSegment.set(.spacing(16))
//      case let .presentTransactScene(id):
//         //         presentTransactModel(transactModel)
//         //         if let id = id {
//         //            transactModel.setSelectedUser(id: id)
//         //         }
//         break
//      case let .presentTransactions(value):
//         tableModel
//            .itemSections(value)
//      case let .presentHistoryDetailView(value):
//         Asset.router?.route(
//            .presentModally(.automatic),
//            scene: \.sentTransactDetails,
//            payload: value
//         )
//      case let .presentHistoryScene(currentUser):
//         Asset.router?.route(
//            .push,
//            scene: \.history,
//            payload: currentUser
//         )
//      case let .setUserProfileInfo(name, imageUrl):
//         profileButton.setState(.text(Design.text.hello + "\n\(name)"))
//         if let url = imageUrl {
//            profileButton.setState(.imageUrl(SpasibkaEndpoints.urlBase + url))
//         }
//      case let .updateAlarmButtonWithNewNotificationsCount(count):
//         if count > 0 {
//            let iconRotationDegrees: CGFloat = 30
//            let iconRotation = iconRotationDegrees * .pi / 180
//            let diameter: CGFloat = count >= 10 ? 16 : 12
//            let countString = count > 99 ? "99" : "\(count)"
//
//            notifyButton.presentActivityModel(
//               LabelModel { model in
//                  model
//                     .set(Design.state.label.bold8)
//                     .backColor(Design.color.background)
//                     .size(.square(diameter))
//                     .cornerCurve(.continuous).cornerRadius(diameter / 2)
//                     .borderWidth(2)
//                     .borderColor(Design.color.iconBrand.darkenColor(0.15))
//                     .textColor(Design.color.iconBrand.darkenColor(0.15))
//                     .numberOfLines(1)
//                     .alignment(.center)
//                     .text(countString)
//                     .view.transform = CGAffineTransformMakeRotation(-iconRotation)
//
//                  let xShift: CGFloat = 3
//                  let rotShift = iconRotation / 1.6666
//
//                  // Animation
//                  UIView.animateKeyframes(withDuration: 10, delay: 3, options: [.repeat, .allowUserInteraction]) {
//                     let translations = [xShift, -xShift]
//                     for i in 0 ..< 6 {
//                        UIView.addKeyframe(withRelativeStartTime: Double(i) * 0.001, relativeDuration: 0.001) {
//                           model.view.transform = CGAffineTransform(translationX: translations[i % 2], y: 0)
//                           self.notifyButton.view
//                              .transform = CGAffineTransform(rotationAngle: i % 2 == 0 ? rotShift : iconRotation)
//                        }
//                     }
//                     UIView.addKeyframe(withRelativeStartTime: 0.006, relativeDuration: 0.001) {
//                        self.notifyButton.view.transform = CGAffineTransform(rotationAngle: iconRotation)
//                        model.view.transform = .identity
//                        model.view.transform = CGAffineTransformMakeRotation(-iconRotation)
//                     }
//                  }
//               },
//               centerShift: CGPoint(x: 1, y: -10)
//            )
//
//            notifyButton.view.transform = CGAffineTransform(rotationAngle: iconRotation)
//         } else {
//            notifyButton.view.transform = .identity
//            notifyButton.hideActivityModel()
//         }
//      }
//   }
//}
