//
//  ChallWinnersViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.10.2022.
//

import StackNinja
import UIKit

final class WinnersViewModel<Design: DSP>: StackModel, Designable, ActivityViewModelProtocol {

   private(set) lazy var activityBlock = ActivityViewModel<Design>()

   private(set)lazy var presenter = ChallWinnersPresenters<Design>()
   private(set)lazy var winnersTableModel = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         presenter.winnersCellPresenter
      )
      .footerModel(Spacer(64))

   override func start() {
      super.start()
      
      arrangedModels([
         activityBlock,
         winnersTableModel
      ])
      
      activityState(.loading)
   }
}

extension WinnersViewModel: StateMachine {
   enum ModelState {
      case presentWinners([ChallengeWinnerReport])
   }
   
   func setState(_ state: ModelState) {
      switch state {
      case let .presentWinners(winners):
         if winners.isEmpty {
            activityState(.empty)
         } else {
            activityState(.hidden)
         }
         winnersTableModel.items(winners)
      }
   }
}
