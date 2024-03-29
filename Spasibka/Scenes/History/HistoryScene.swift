//
//  HistoryScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 16.08.2022.
//

import StackNinja
import UIKit

// MARK: - HistoryScene

struct HistorySceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = UserData
      typealias Output = Void
   }
}

final class HistoryScene<Asset: ASP>: BaseParamsScene<HistorySceneParams<Asset>>,
   Scenarible
{
   private lazy var viewModels = HistoryViewModels<Design>()

   lazy var scenario = HistoryScenario(
      works: HistoryWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: HistoryScenarioEvents(
         initial: Work.void,
         loadHistoryForCurrentUser: on(\.input),
         filterTapped: viewModels.filterButtons.on(\.didTapButtons),
         presentDetailView: viewModels.tableModel.on(\.didSelectRow),
         showCancelAlert: viewModels.presenter.on(\.presentAlert),
         cancelTransact: viewModels.presenter.on(\.cancelButtonPressed),
         requestPagination: viewModels.tableModel.on(\.requestPagination),
         groupFilterTapped: viewModels.groupFilter.on(\.didSelected)
      )
   )

   private lazy var activityIndicator = Design.model.common.activityIndicator
   private lazy var errorBlock = Design.model.common.connectionErrorBlock

   // MARK: - Start

   override func start() {
      configure()
      if #available(iOS 15.0, *) {
         viewModels.tableModel.view.sectionHeaderTopPadding = 8
      } else {
         // Fallback on earlier versions
      }
      viewModels.tableModel
         .presenters(
            viewModels.presenter.transactToHistoryCell,
            SpacerPresenter.presenter
         )

//      viewModels.tableModel
//         .on(\.didScroll) { [weak self] in
//            self?.send(\.didScroll, $0.velocity)
//         }
//         .on(\.willEndDragging) { [weak self] in
//            self?.send(\.willEndDragging, $0.velocity)
//         }
//         .activateRefreshControl(color: Design.color.iconBrand)
//         .on(\.refresh, self) {
//            $0.send(\.payload, nil)
//         }

      setState(.initial)
      scenario.configureAndStart()
   }

   func presentSentTransactions() {
      viewModels.filterButtons.setButtonTapped(.didTapButton3)
   }

   func presentRecievedTransactions() {
      viewModels.filterButtons.setButtonTapped(.didTapButton2)
   }
}

// MARK: - Configure presenting

private extension HistoryScene {
   func configure() {
      mainVM.navBar.titleLabel
         .text(Design.text.history)
      mainVM.navBar.secondaryButtonHidden(true)
      viewModels.tableModel.view
      mainVM.bodyStack
         .axis(.vertical)
         .arrangedModels([
            Grid.x16.spacer,
            viewModels.filterButtons.lefted().padding(.left(16)),
//            Grid.x16.spacer,
//            viewModels.groupFilter.lefted().padding(.left(16)),
            Grid.x16.spacer,
            activityIndicator,
            errorBlock,
            viewModels.tableModel,
            Spacer(),
         ])
   }
}

enum HistoryState {
   case initial

   case loadProfilError
   case loadTransactionsError

   case presentTransactions([TableItemsSection])
   case presentDetailView(Transaction)

   case cancelTransaction
   case cancelAlert(Int)
   case showActivityIndicator
   case presentGroupTransactions([TableItemsSection])
   case setNormalMode
   case clearTableModel
}

extension HistoryScene: StateMachine {
   func setState(_ state: HistoryState) {
      switch state {
      case .initial:
         activityIndicator.hidden(false)
         errorBlock.hidden(true)
      case .loadProfilError:
         errorBlock.hidden(false)
         scenario.events.initial.doAsync()
      //
      case .loadTransactionsError:
         errorBlock.hidden(false)
         activityIndicator.hidden(true)
         scenario.events.initial.doAsync()
      //
      case let .presentTransactions(value):
         errorBlock.hidden(true)
         activityIndicator.hidden(true)
         viewModels.tableModel.hidden(false)

         viewModels.tableModel
            .presenters(
               viewModels.presenter.transactToHistoryCell,
               SpacerPresenter.presenter
            )

         viewModels.tableModel
            .itemSections(value)
      //
      case let .presentDetailView(value):
         Asset.router?.route(.presentModally(.automatic),
                             scene: \.sentTransactDetails,
                             payload: value)
      case .cancelTransaction:
         scenario.events.initial.doAsync()
         print("transaction cancelled")

      case let .cancelAlert(id):
         // Create Alert
         let dialogMessage = UIAlertController(title: nil,
                                               message: Design.text.cancelTransferQuestion,
                                               preferredStyle: .alert)

         let yes = UIAlertAction(title: Design.text.yes, style: .default, handler: { [weak self] _ in
            print("Yes button tapped")
            self?.viewModels.presenter.send(\.cancelButtonPressed, id)
         })

         let no = UIAlertAction(title: Design.text.no, style: .cancel) { _ in
            print("No button tapped")
         }

         dialogMessage.addAction(yes)
         dialogMessage.addAction(no)

         UIApplication.shared.windows.first?.rootViewController?.present(dialogMessage, animated: true, completion: nil)
      case .showActivityIndicator:
         activityIndicator.hidden(false)
         errorBlock.hidden(true)
      case let .presentGroupTransactions(value):

         mainVM.bodyStack
            .arrangedModels([
               Grid.x16.spacer,
               viewModels.groupFilter.lefted().padding(.left(16)),
               Grid.x16.spacer,
               activityIndicator,
               errorBlock,
               viewModels.tableModel,
               Spacer(),
            ])

         viewModels.filterButtons.hidden(true)
         viewModels.tableModel
            .presenters(
               viewModels.groupTransactPresenter.transactToHistoryCell,
               SpacerPresenter.presenter
            )
         viewModels.tableModel
            .itemSections(value)
      case .setNormalMode:
         activityIndicator.hidden(false)
         viewModels.filterButtons.hidden(false)
         viewModels.tableModel.hidden(true)

         mainVM.bodyStack
            .arrangedModels([
               Grid.x16.spacer,
               viewModels.filterButtons.lefted().padding(.left(16)),
               Grid.x16.spacer,
               viewModels.groupFilter.lefted().padding(.left(16)),
               Grid.x16.spacer,
               activityIndicator,
               errorBlock,
               viewModels.tableModel,
               Spacer(),
            ])

         let index = viewModels.filterButtons.selectedIndex
         let button = Button3Event(rawValue: index) ?? .didTapButton1
         scenario.events.filterTapped.sendAsyncEvent(button)
      case .clearTableModel:
         viewModels.tableModel.itemSections([])
      }
   }
}
