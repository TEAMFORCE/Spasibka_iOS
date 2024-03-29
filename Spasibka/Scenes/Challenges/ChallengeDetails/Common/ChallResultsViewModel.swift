//
//  ChallResultsViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.10.2022.
//

import StackNinja
import UIKit

final class ChallResultsViewModel<Design: DSP>: StackModel, Designable, ActivityViewModelProtocol {
   private(set) lazy var activityBlock = ActivityViewModel<Design>()

   let presenter = ChallResultsPresenters<Design>()

   private(set) lazy var resultsTableModel = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         presenter.resultsCellPresenter
      )
      .footerModel(Spacer(64))

   override func start() {
      super.start()

      arrangedModels([
         activityBlock,
         resultsTableModel,
      ])

      activityState(.loading)
   }
}

extension ChallResultsViewModel: SetupProtocol {
   func setup(_ data: [ChallengeResult]) {
      if data.isEmpty {
         activityState(.empty)
      } else {
         activityState(.hidden)
      }
      resultsTableModel.items(data)
   }
}
