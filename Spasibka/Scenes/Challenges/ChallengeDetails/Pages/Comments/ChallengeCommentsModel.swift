//
//  ChallengeCommentsBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

// MARK: - ChallengeCommentsBlock

final class ChallengeCommentsModel<Asset: AssetProtocol>:
   BaseViewModelWrapper<CommentsViewModel<Asset.Design>>, PayloadedScenarible, Eventable
{
   typealias Events = ChallengeDetailsPageEvents
   var events = EventsStore()
   
   private(set) lazy var scenario = ChallengeCommentsScenario<Asset>(
      works: .init(),
      stateDelegate: stateDelegate,
      events: .init(
         didEditingComment: viewModel.commentPanelModel.subModel.models.main.on(\.didEditingChanged),
         didSendCommentPressed: viewModel.commentPanelModel.subModel.models.right.on(\.didTap),
         commentLiked: viewModel.presenter.on(\.reactionPressed),
         deleteCommentAtIndex: viewModel.commentTableModel.on(\.deleteItemAtIndex)
      )
   )

   override func start() {
      super.start()
      
      viewModel.commentTableModel.on(\.willEndDragging, self) {
         $0.send(\.willEndDragging, $1)
      }
   }
}

enum ChallengeCommentsState {
   case error
   case presentComments([Comment])
   case updateCommentAtIndex(Comment, Int)
   case updateCommentInput(String)
   case sendButtonDisabled
   case sendButtonEnabled
   case commentDidSend
}

extension ChallengeCommentsModel: StateMachine {
   func setState(_ state: ChallengeCommentsState) {
      switch state {
      case let .presentComments(comments):
         viewModel.setState(.presentComments(comments))
      case .error:
         break
      case let .updateCommentAtIndex(value, index):
         viewModel.commentTableModel.updateItemAtIndex(value, index: index)
      case let .updateCommentInput(text):
         viewModel.commentPanelModel.subModel.models.main.text(text)
      case .sendButtonDisabled:
         viewModel.commentPanelModel.subModel.models.right.setMode(\.inactive)
      case .sendButtonEnabled:
         viewModel.commentPanelModel.subModel.models.right.setMode(\.normal)
      case .commentDidSend:
         viewModel.commentPanelModel.subModel.models.main.text("")
         setState(.sendButtonDisabled)
      }
   }
}
