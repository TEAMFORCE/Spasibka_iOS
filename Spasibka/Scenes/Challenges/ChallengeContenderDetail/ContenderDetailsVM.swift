//
//  ChallCandidateDetailsVM.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.12.2022.
//

import StackNinja
import UIKit

enum ContenderDetailsState {
   case initial(ContenderDetailsSceneInput)
   case details(ContenderDetailsSceneInput)
   case comments([Comment])
   case reactions([ReactItem])
   case loadingActivity

   case sendButtonDisabled
   case sendButtonEnabled
   case commentDidSend
   case hereIsEmpty
}

final class ContenderDetailViewModels<Asset: AssetProtocol>: BodyFooterStackModel, Assetable {
   // var events: EventsStore = .init()

   lazy var infoBlock = FeedDetailUserInfoBlock<Design>()

   lazy var filterButtons = FeedDetailFilterButtons<Design>()
      .padHorizontal(16)

   lazy var commentsBlock = CommentsViewModel<Design>()
   lazy var reactionsBlock = ReactItemsViewModel<Design>()

   lazy var detailsBlock = FeedDetailsBlock<Asset>()

   override func start() {
      super.start()

      bodyStack.arrangedModels([
         infoBlock,
         filterButtons
      ])

      filterButtons.buttonDetails.setMode(\.selected)
   }
}

// extension ContenderDetailViewModels: Eventable {
//   struct Events: InitProtocol {
//      // var reactionPressed: PressLikeRequest?
//      var saveInput: Feed?
//   }
// }

extension ContenderDetailViewModels: StateMachine {
   func setState(_ state: ContenderDetailsState) {
      switch state {
      case let .initial(input):
         switch input {
         case let .contender(contender):
            infoBlock.setupContenderInfo(contender: contender)
         case let .winnerReport(report):
            infoBlock.setupWinnerInfo(report: report)
         case .winnerReportId:
            break
         }

         setState(.details(input))
      case let .details(input):
         footerStack.arrangedModels([
            ScrollStackedModelY()
               .set(.arrangedModels([
                  detailsBlock
               ]))

         ])

         switch input {
         case let .contender(contender):
            detailsBlock.setupContender(contender)
         case let .winnerReport(winner):
            detailsBlock.setupWinner(winner)
         case .winnerReportId:
            break
         }

      case let .comments(comments):

         footerStack.arrangedModels([
            commentsBlock
         ])
         commentsBlock.setState(.presentComments(comments))
      case let .reactions(items):

         footerStack.arrangedModels([
            reactionsBlock,
            Spacer()
         ])
         reactionsBlock.setup(items)
      case .loadingActivity:
         footerStack.arrangedModels([
            Design.model.common.activityIndicatorSpaced
         ])
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
