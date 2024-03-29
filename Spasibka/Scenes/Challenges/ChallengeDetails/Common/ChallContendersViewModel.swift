//
//  ChallContendersViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.10.2022.
//

import StackNinja
import UIKit

final class CandidatesViewModel<Design: DSP>: StackModel, Designable, ActivityViewModelProtocol {
   
   private(set) lazy var activityBlock = ActivityViewModel<Design>()
   
   private(set) lazy var presenter = ChallContendersPresenters<Design>()
   
   private(set) lazy var contendersTableModel = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         presenter.contendersCellPresenter
      )
      .footerModel(Spacer(64))

   override func start() {
      super.start()
      
      arrangedModels([
         activityBlock,
         contendersTableModel
      ])
      
      activityState(.loading)
   }
}

extension CandidatesViewModel: StateMachine {
   enum ModelState {
      case presentCandidates([Contender])
   }
   
   func setState(_ state: ModelState) {
      switch state {
      case let .presentCandidates(candidates):
         if candidates.isEmpty {
            activityState(.empty)
         } else {
            activityState(.hidden)
         }
         contendersTableModel.items(candidates)
      }
   }
}
