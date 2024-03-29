//
//  FeedViewModels.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.08.2022.
//

import StackNinja
import UIKit

final class FeedTableModelBlock<Design: DSP>: StackModel {
   let delegate: EventsCellPresenter<Design>

   required init(delegate: EventsCellPresenter<Design>) {
      self.delegate = delegate
      super.init()

      feedTableModel.presenters(
         delegate.presenter,
         SpacerPresenter.presenter
      )
   }

   required init() {
      fatalError()
   }

   private(set) lazy var feedTableModel = TableItemsModel()
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()

   private let activityIndicator = Design.model.common.activityIndicator
   private let errorBlock = Design.model.common.connectionErrorBlock
   private let hereIsEmptyBlock = HereIsEmptySpacedBlock<Design>()

   private var userName = ""

   override func start() {
      super.start()

      setState(.loading)
      arrangedModels([
         activityIndicator,
         errorBlock,
         hereIsEmptyBlock,
         feedTableModel,
         Spacer(),
      ])
   }
}

enum FeedViewModelsState {
   case loading
   case loadFeedError
//   case updateFeedAtIndex(Feed, Int)

//   case setPresenters([PresenterProtocol])
   case presentEvents([FeedEvent])
}

extension FeedTableModelBlock: StateMachine {
   func setState(_ state: FeedViewModelsState) {
      switch state {
      case .loading:
         activityIndicator.hidden(false)
         errorBlock.hidden(true)
         hereIsEmptyBlock.hidden(true)
         feedTableModel.hidden(true)
//      case let .presentFeed(tuple):
//         hereIsEmptyBlock.hidden(true)
//         activityIndicator.hidden(true)
//         errorBlock.hidden(true)
//         userName = tuple.1
//
//         guard !tuple.0.isEmpty else {
//            feedTableModel.hidden(true)
//            hereIsEmptyBlock.hidden(false)
//            return
//         }
//
//         feedTableModel.hidden(false)
//         feedTableModel.items(tuple.0 + [SpacerItem(96)])
      case .loadFeedError:
         log("Feed Error!")
         activityIndicator.hidden(true)
         feedTableModel.hidden(true)
         errorBlock.hidden(false)
//      case let .updateFeedAtIndex(feed, index):
//         feedTableModel.updateItemAtIndex(feed, index: index)

      // MARK: - New

//      case let .setPresenters(presenters):
//         feedTableModel.presenters(presenters)
      case let .presentEvents(events):
         hereIsEmptyBlock.hidden(true)
         activityIndicator.hidden(true)
         errorBlock.hidden(true)
         userName = ""

         guard !events.isEmpty else {
            feedTableModel.hidden(true)
            hereIsEmptyBlock.hidden(false)
            return
         }

         feedTableModel.hidden(false)
         feedTableModel.items(events + [SpacerItem(96)])
      }
   }
}
