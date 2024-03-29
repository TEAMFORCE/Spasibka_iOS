//
//  MainScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.06.2022.
//

import StackNinja
import UIKit

typealias ScenaribleEventableUIViewModel = Scenarible & Eventable & UIViewModel

enum MainSceneState {
   // Начальное состояние сцены
   case initial
   // Состояние, когда профиль пользователя успешно загружен
   case profileDidLoad(UserData)
   // Состояние, когда произошла ошибка при загрузке профиля пользователя
   case loadProfileError

   case presentMarketplace
   case presentHistory
   case presentAnalytics
   case presentAwards
   case presentSettings(UserData)
   case presentEmployees
   case presentChallenge(MainSceneInput)
   case presentMainMenu

   case presentUserDataNotFilledPopup
}

enum MainSceneInput {
   case challengeId(Int)
   case normal
}

final class MainScene<Asset: AssetProtocol>:
   BaseSceneModel<
      DefaultVCModel,
      MainScreenVM<Asset.Design>,
      Asset,
      MainSceneInput,
      Void
   >, Scenarible, Configurable
{
   // Сценарий, описывающий работу сцены
   lazy var scenario = MainScenario(
      works: MainWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: MainScenarioInputEvents(
         input: on(\.input),
         myAvatarDidChanged: updateMyProfileFinishWork,
         sideMenuMarketplace: sideMenu.on(\.didSelectMarketplace),
         sideMenuHistory: sideMenu.on(\.didSelectHistory),
         sideMenuAnalytics: sideMenu.on(\.didSelectAnalytics),
         sideMenuEmployees: sideMenu.on(\.didSelectEmployees),
         sideMenuAwards: sideMenu.on(\.didSelectAwards),
         sideMenuSettings: sideMenu.on(\.didSelectSettings),
         reloadNewNotifies: Work.void
      )
   )

   // Длительность анимации открытия side menu
   private let sideMenuAnimationDuration: CGFloat = 0.36

   // Модель представления экрана "Баланс"
//   private lazy var balanceViewModel = BalanceSceneViewModel<ProductionAsset>()

   // Модель представления экрана "История"
   private lazy var historyViewModel = HistoryScene<Asset>()
   // Модель представления экрана "События"
   private lazy var feedViewModel = FeedScene<Asset>()
   // Модель представления экрана "Испытания"
   private lazy var challengesViewModel = ChallengeGroupSceneViewModel<Asset>()
   // Модель представления экрана "Транзакции"
   private lazy var transactModel: TransactSceneViewModel = TransactSceneViewModel<Asset>(vcModel: vcModel)
   // Модель представления экрана "Маркетплейс"
   private lazy var marketplaceViewModel = MarketScene<Asset>()
   // Модель представления экрана "Cотрудники"
   private lazy var employeesViewModel = EmployeesScene<Asset>()
   // Модель представления экрана "Награды"
   private lazy var awardsScene = AwardsScene<Asset>()
   // Модель представления экрана "Фильтр Маркетплейса"
   private lazy var marketplaceFilterModel = MarketFilterScene<Asset>()

   private lazy var mainMenu = MainMenuSceneViewModel<Asset>()

   // Нижняя панель навигации
   private lazy var tabBarPanel: TabBarPanel<Design> = .init()
      .shadow(Design.params.cellShadow)

   // Данные текущего пользователя
   private var currentUser: UserData?

   // Модель представления блока с ошибкой соединения
   private lazy var errorBlock = StackModel()
      .arrangedModels(
         Design.model.common.connectionErrorBlock,
         Design.button.default
            .setNeedsStoreModelInView()
            .title(Design.text.repeat)
            .on(\.didTap) { [weak self] in
               self?.start()
            }
      )
      .spacing(96)

   // Текущее состояние сцены
   private var currentState = MainSceneState.initial

   // Презентер нижнего всплывающего окна
   private(set) lazy var bottomPopupPresenter = BottomPopupPresenter()

   private lazy var userDataNotFilledPopup = DialogPopupVM<Design>()

   // Индекс выбранной модели представления в нижней панели навигации
   enum SelectedModel {
      case feed
      case balance
      case challenges
      case history
      case market
      case awards
      case employees
      case mainMenu
   }

   private lazy var selectedModel: SelectedModel = .mainMenu
   private lazy var challengeId: Int? = nil

   private let updateMyProfileFinishWork = Out<UIImage>()

   // side menu

   private lazy var sideMenu = SideMenu<Design>()

   private lazy var superViewRecognizer = {
      let tap = UITapGestureRecognizer()
      tap.addTarget(self, action: #selector(didTapSuperView))
      return tap
   }()

   // MARK: - Start

   override func start() {
     // vcModel?.navBarHidden(true)

      mainVM.setState(.loading)
      scenario.configureAndStart()

      vcModel?.on(\.viewWillAppearByBackButton, self) {
         $0.scenario.events.reloadNewNotifies.doAsync()
      }

      tabBarPanel.button1.setMode(\.normal)
      selectedModel = .mainMenu
   }

   func configure() {
      mainVM.setState(.ready)

      let brightness = Design.color.backgroundBrand.brightnessStyle()

      switch brightness {
      case .dark:
         vcModel?
            .navBarTintColor(Design.color.iconInvert)
            .titleColor(Design.color.iconInvert)
            .statusBarStyle(.lightContent)
      case .light:
         vcModel?
            .navBarTintColor(Design.color.iconBrand)
            .titleColor(Design.color.iconBrand)
            .statusBarStyle(.darkContent)
      }

      mainVM.bodyStack.arrangedModels([
         Design.model.common.activityIndicatorSpaced
      ])

      mainVM.backViewModel(sideMenu)

      vcModel?.on(\.viewWillAppear, self) {
         $0.vcModel?
            .navBarBackColor(Design.color.transparent)
            .navBarTranslucent(true)
         $0.scenario.events.reloadNewNotifies.doAsync()
      }

      mainVM.subModel.addModel(tabBarPanel) { anchors, superview in
         anchors
            .left(superview.leftAnchor, 16)
            .right(superview.rightAnchor, -16)
            .bottom(superview.safeAreaLayoutGuide.bottomAnchor)
      }
   }

   private func unlockTabButtons() {
      tabBarPanel.button1.setMode(\.inactive)
      tabBarPanel.button2.setMode(\.inactive)
      tabBarPanel.button3.setMode(\.inactive)
      tabBarPanel.button4.setMode(\.inactive)
   }

   @objc private func didTapSuperView() {
      hideSideMenu()
   }
}

private extension MainScene {
   func configButtons() {
      tabBarPanel.button1
         .on(\.didTap, self) {
            $0.unlockTabButtons()
            $0.selectedModel = .mainMenu
            $0.presentModel($0.mainMenu)
            $0.tabBarPanel.button1.setMode(\.normal)
         }

      tabBarPanel.button2
         .on(\.didTap, self) {
//            $0.unlockTabButtons()
//            $0.selectedModel = .balance
//            $0.presentModel($0.balanceViewModel)
            $0.tabBarPanel.button2.setMode(\.normal)
         }

      tabBarPanel.buttonMain
         .on(\.didTap, self) { slf in
            slf.presentTransactModel(slf.transactModel) {
               if slf.selectedModel == .history {
                  slf.historyViewModel.scenario.configureAndStart()
               }
            }
         }

      tabBarPanel.button3
         .on(\.didTap, self) {
            $0.challengeButtonConfigures()
         }

      tabBarPanel.button4
         .on(\.didTap, self) {
            $0.presentSideMenu()
         }
   }

   func challengeButtonConfigures() {
      selectedModel = .challenges
      unlockTabButtons()
      presentModel(challengesViewModel)
      tabBarPanel.button3.setMode(\.normal)
   }
}

// MARK: - State machine

extension MainScene: StateMachine {
   func setState(_ state: MainSceneState) {
      currentState = state

      switch state {
      case .initial:
         break
      case let .profileDidLoad(userData):
         configure()

         currentUser = userData
         sideMenu.logoModel.updateIcon()
         tabBarPanel.button1.setMode(\.normal)

         switch selectedModel {
         case .feed:
            break
         case .balance:
//            presentModel(balanceViewModel)
            break
         case .history:
            Asset.router?.route(.push, scene: \.history, payload: currentUser)
         case .challenges:
            challengeButtonConfigures()
         case .market:
//            presentModel(marketplaceViewModel)
            break
         case .employees:
            Asset.router?.route(.push, scene: \.employees)
         case .awards:
//            presentModel(awardsScene)
            break
         case .mainMenu:
            presentModel(mainMenu)
         }

         configButtons()
      case .loadProfileError:
         mainVM.setState(.presentErrorModel(errorBlock))

      // Side menu
      case .presentMarketplace:
         unlockTabButtons()
//         presentModel(marketplaceViewModel)
         tabBarPanel.button4.setMode(\.normal)
         selectedModel = .market
         hideSideMenu()
      case .presentHistory:
         hideSideMenu()
         Asset.router?.route(.push, scene: \.history, payload: currentUser)
      case .presentEmployees:
         hideSideMenu()
         Asset.router?.route(.push, scene: \.employees)
      case .presentAnalytics:
         hideSideMenu()
      case let .presentSettings(userData):
         hideSideMenu()
         Asset.router?.route(.push, scene: \.settings, payload: userData)
      case let .presentChallenge(value):
         switch value {
         case let .challengeId(value):
            challengeId = value
            selectedModel = .challenges
         case .normal:
            break
         }
      case .presentUserDataNotFilledPopup:
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }

            self.userDataNotFilledPopup.setState(
               .init(
                  image: Design.icon.smartPeopleIllustrate,
                  title: Design.text.noUserDataWarning,
                  subtitle: nil,
                  buttonText: Design.text.goToSettings,
                  buttonSecondaryText: Design.text.cancel
               )
            )
            self.bottomPopupPresenter.setState(.presentWithAutoHeight(
               model: self.userDataNotFilledPopup,
               onView: self.vcModel?.superview
            ))
            self.userDataNotFilledPopup.didTapButtonWork
               .onSuccess(self) {
                  $0.bottomPopupPresenter.setState(.hide)
                  Asset.router?.route(.push, scene: \.myProfile)
               }
            self.userDataNotFilledPopup.didTapCancelButtonWork
               .onSuccess(self.bottomPopupPresenter) {
                  $0.setState(.hide)
               }
         }
      case .presentAwards:
         unlockTabButtons()
//         presentModel(awardsScene)
         tabBarPanel.button4.setMode(\.normal)
         selectedModel = .awards
         hideSideMenu()
      case .presentMainMenu:
         unlockTabButtons()
      }
   }
}

// MARK: - Presenting sub scenes

extension MainScene {
   // Presenting Balance, Feed, History
   private func presentModel<M: ScenaribleEventableUIViewModel>(_ model: M)
      where M.Events == MainSceneEvents<UserData?>
   {
      if selectedModel == .mainMenu {
         mainVM.bodyStack
            .set(Design.state.stack.mainSceneMainMenuStack)
      } else {
         mainVM.bodyStack
            .set(Design.state.stack.mainSceneStack)
      }

      mainVM.bodyStack
         .arrangedModels([
            model
         ])


      model.scenario.configureAndStart()
      model.send(\.payload, currentUser)
      if selectedModel == .challenges {
         if let challengeId = challengeId {
            Asset.router?.route(
               .push,
               scene: \.challengeDetails,
               payload: ChallengeDetailsInput.byId(challengeId)
            )
         }
         challengeId = nil
      }
   }
}

extension MainScene {
   func presentSideMenu() {
      mainVM.mainModel.userInterractionEnabled(false)

      vcModel?.view.superview?.addGestureRecognizer(superViewRecognizer)
      vcModel?.navBarHidden(true)

      let viewFrame = mainVM.mainModel.view.frame
      let shiftX = viewFrame.width / 1.354
      UIView.animate(withDuration: 0) {
         self.mainVM.mainModel.view.layer.cornerRadius = Design.params.sceneCornerRadius
         self.mainVM.mainModel.view.clipsToBounds = true
      } completion: { _ in
         UIView.animate(withDuration: self.sideMenuAnimationDuration) {
            self.mainVM.mainModel.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
               .translatedBy(x: shiftX, y: 0)
         }
      }
   }

   func hideSideMenu() {
      mainVM.mainModel.userInterractionEnabled(true)

      vcModel?.view.superview?.removeGestureRecognizer(superViewRecognizer)
      vcModel?.navigationController?.navigationBar.isHidden = false

      UIView.animate(withDuration: sideMenuAnimationDuration) {
         self.mainVM.mainModel.view.transform = .identity
      } completion: { _ in
         UIView.animate(withDuration: 0) {
            self.mainVM.mainModel.view.layer.cornerRadius = 0
            self.mainVM.mainModel.view.clipsToBounds = false
         }
      }
   }
}

extension MainScene: TransactPopupPresenterProtocol {}
