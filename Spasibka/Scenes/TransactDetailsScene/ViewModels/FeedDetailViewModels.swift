//
//  FeedDetailScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 29.09.2022.
//

import StackNinja
import UIKit

enum FeedDetailsState {
   case initial(feed: Feed, curUsername: String)
   case details(EventTransaction)
   case comments([Comment])
   case reactions([ReactItem])
   case loadingActivity

   case sendButtonDisabled
   case sendButtonEnabled
   case commentDidSend
   case hereIsEmpty
}

final class FeedDetailViewModels<Asset: AssetProtocol>: BodyFooterStackModel, Assetable {
   var events: EventsStore = .init()

   lazy var infoBlock = FeedDetailUserInfoBlock<Design>()

   lazy var filterButtons = FeedDetailFilterButtons<Design>()
      .padLeft(16)

   lazy var commentsBlock = CommentsViewModel<Design>()
   lazy var reactionsBlock = ReactItemsViewModel<Design>()

   lazy var detailsBlock = FeedDetailsBlock<Asset>()
   
   private lazy var commentsTitle = LabelModel()
      .text(Design.text.comments)
      .set(Design.state.label.labelRegular14)
      .padLeft(16)
   
   private lazy var scrollWrapper = ScrollStackedModelY()
      .set(.bounce(false))
      .set(.arrangedModels([
         infoBlock,
         //filterButtons,
         detailsBlock,
         Spacer(20),
         commentsTitle,
         commentsBlock.activityBlock,
         commentsBlock.commentTableModel
      ]))

   override func start() {
      super.start()

      bodyStack.arrangedModels([
         scrollWrapper
      ])
      
      footerStack.arrangedModels([
//         commentsBlock.commentPanel
         commentsBlock.commentPanelModel.padHorizontal(16)
      ])

      filterButtons.buttonDetails.setMode(\.selected)
   }
}

extension FeedDetailViewModels: Eventable {
   struct Events: InitProtocol {
      // var reactionPressed: PressLikeRequest?
      var saveInput: Feed?
   }
}

extension FeedDetailViewModels: StateMachine {
   func setState(_ state: FeedDetailsState) {
      switch state {
      case .initial(let feedElement, let curUserName):
         send(\.saveInput, feedElement)
         if let transaction = feedElement.transaction {
            infoBlock.setup((transaction, curUserName))
           // setState(.details(transaction))
         }
      case .details(let feed):
         detailsBlock.setup(feed)

      case .comments(let comments):
         commentsBlock.setState(.presentComments(comments))

      case .reactions(let items):
         reactionsBlock.setup(items)
         footerStack.arrangedModels([
            reactionsBlock,
            Spacer()
         ])
      case .loadingActivity:
//         footerStack.arrangedModels([
//            Design.model.common.activityIndicatorSpaced
//         ])
         break
      case .sendButtonDisabled:
         commentsBlock.setState(.sendButtonDisabled)
      case .sendButtonEnabled:
         commentsBlock.setState(.sendButtonEnabled)
      case .commentDidSend:
         commentsBlock.commentPanelModel.subModel.models.main.text("")
         commentsBlock.setState(.sendButtonDisabled)
      case .hereIsEmpty:
         footerStack.arrangedModels([
            HereIsEmptySpacedBlock<Design>()
         ])
      }
   }
}
