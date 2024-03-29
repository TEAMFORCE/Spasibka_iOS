//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.10.2022.
//

import StackNinja
import UIKit

final class ReactItemsViewModel<Design: DSP>: StackModel, Designable, ActivityViewModelProtocol {
   
   private(set) lazy var activityBlock = ActivityViewModel<Design>()
   
   private(set) lazy var filterButtons = FeedReactionsFilterButtons<Design>()
      .hidden(true)
   
   private(set) lazy var reactedUsersTableModel = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         ReactionsPresenters<Design>().reactionsCellPresenter
      )
      .footerModel(Spacer(64))
   
   override func start() {
      super.start()
      
      arrangedModels([
         filterButtons,
         activityBlock,
         reactedUsersTableModel
      ])
      
      activityState(.loading)
   }
}

extension ReactItemsViewModel: SetupProtocol {
   func setup(_ data: [ReactItem]) {
      if data.isEmpty {
         activityState(.empty)
      } else {
         activityState(.hidden)
      }
      reactedUsersTableModel.items(data.splitByPairs)
   }
}
