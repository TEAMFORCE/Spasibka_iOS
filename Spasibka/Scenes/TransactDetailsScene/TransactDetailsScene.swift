//
//  FeedDetailViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 26.09.2022.
//

import StackNinja
import UIKit

struct TransactDetailsSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = TransactDetailsSceneInput
      typealias Output = Void
   }
}

enum TransactDetailsSceneInput {
   case feedElement(Feed)
   case transactId(Int, Bool? = nil)
}

final class TransactDetailsScene<Asset: ASP>: BaseParamsScene<TransactDetailsSceneParams<Asset>>, Scenarible {
   typealias State = ViewState
   typealias State2 = StackState

   private lazy var feedDetailVM = FeedDetailViewModels<Asset>()

   lazy var scenario = TransactDetailsScenario<Asset>(
      works: TransactDetailsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: FeedDetailEvents(
         presentDetails: feedDetailVM.filterButtons.on(\.didTapDetails),
         presentComment: feedDetailVM.filterButtons.on(\.didTapComments),
         presentReactions: feedDetailVM.filterButtons.on(\.didTapReactions),
         reactionPressed: feedDetailVM.infoBlock.on(\.reactionPressed),
         userAvatarPressed: feedDetailVM.infoBlock.on(\.userAvatarPressed),
         saveInput: on(\.input),
         didEditingComment: feedDetailVM.commentsBlock.commentPanelModel.subModel.models.main.on(\.didEditingChanged),
         didSendCommentPressed: feedDetailVM.commentsBlock.commentPanelModel.subModel.models.right.on(\.didTap),
         presentAllReactions: feedDetailVM.reactionsBlock.filterButtons.on(\.didTapAll),
         presentLikeReactions: feedDetailVM.reactionsBlock.filterButtons.on(\.didTapLikes),
         commentLiked: feedDetailVM.commentsBlock.presenter.on(\.reactionPressed),
         presentProfile: feedDetailVM.infoBlock.on(\.didSelectProfile),
         deleteCommentAtIndex: feedDetailVM.commentsBlock.commentTableModel.on(\.deleteItemAtIndex),
         presentLikesScene: feedDetailVM.detailsBlock.likesAmountLabel.on(\.didTap)
      )
   )

   override func start() {
      vcModel?
         .title(Design.text.gratitude)
      mainVM.navBar
         .titleLabel.text(Design.text.gratitude)
      
      mainVM.navBar.menuButton.image(nil)

      configure()
   }

   private var state = FeedDetailSceneState.initial

   private func configure() {
//      mainVM.headerStack.arrangedModels([Spacer(8)])
      mainVM.bodyStack
         .set(Design.state.stack.brandShiftedBodyStackNew)
         .safeAreaOffsetDisabled()
         .alignment(.fill)
         .distribution(.fill)
         .set(.backColor(Design.color.background))
         .arrangedModels([
            Spacer(32),
            feedDetailVM
         ])

      setState(.initial)

      scenario.configureAndStart()
   }
}

enum FeedDetailSceneState {
   case initial
   case present(feed: Feed, currentUsername: String)
   case presentDetails(transaction: EventTransaction, currentUsername: String)
   case presentComments([Comment])
   case presentReactions([ReactItem])
   case buttonLikePressed(alreadySelected: Bool)
   case failedToReact(alreadySelected: Bool)
   case updateReactions((LikesCommentsStatistics, Bool))
   case presntActivityIndicator
   case sendButtonDisabled
   case sendButtonEnabled
   case commentDidSend
   case hereIsEmpty
   case presentUserProfile(Int)
   case updateCommentAtIndex(Comment, Int)

   case updateCommentInputField(String)
   case sendCommentEvent
   case nothing

   case error
   
   case presentLikesScene(EventTransaction)
}

extension TransactDetailsScene: StateMachine {
   func setState(_ state: FeedDetailSceneState) {
      self.state = state
      switch state {
      case .initial:
         feedDetailVM.setState(.loadingActivity)
      //
      case .present(let feed, let userName):
         feedDetailVM.setState(.initial(feed: feed, curUsername: userName))
      //
      case .presentDetails(let transaction, let userName):
         feedDetailVM.infoBlock.setup((transaction, userName))
         feedDetailVM.setState(.details(transaction))
      //
      case .presentComments(let comments):
         feedDetailVM.setState(.comments(comments))
      //
      case .presentReactions(let items):
         feedDetailVM.setState(.reactions(items))
      //
      case .failedToReact(let selected):
         print("failed to like")
         setState(.buttonLikePressed(alreadySelected: !selected))
      //
      case .updateReactions(let value):
         if let reactions = value.0.likes {
            for reaction in reactions {
               if reaction.likeKind?.code == "like" {
                  feedDetailVM.detailsBlock.likesAmountLabel.text(Design.text.liked + " " + String(reaction.counter ?? 0))
               }
            }
         }
      //
      case .presntActivityIndicator:
         feedDetailVM.setState(.loadingActivity)
      //
      case .sendButtonDisabled:
         feedDetailVM.setState(.sendButtonDisabled)
      //
      case .sendButtonEnabled:
         feedDetailVM.setState(.sendButtonEnabled)
      //
      case .commentDidSend:
         feedDetailVM.filterButtons.send(\.didTapComments)
         feedDetailVM.setState(.commentDidSend)
      //
      case .error:
         print("Load token error")
      case .buttonLikePressed(let selected):
         if selected {
            feedDetailVM.infoBlock.likeButton.setState(.none)
         } else {
            feedDetailVM.infoBlock.likeButton.setState(.selected)
         }
      //
      case .presentUserProfile(let userId):
         Asset.router?.route(.push, scene: \.profile, payload: userId)
      //
      case .hereIsEmpty:
         feedDetailVM.setState(.hereIsEmpty)
      //
      case .updateCommentAtIndex(let value, let index):
         feedDetailVM.commentsBlock.commentTableModel.updateItemAtIndex(value, index: index)
      //
      case .updateCommentInputField(let value):
         feedDetailVM.commentsBlock.commentPanelModel.subModel.models.main.text(value)
      case .sendCommentEvent:
         feedDetailVM.filterButtons.buttonDetails.setMode(\.normal)
         feedDetailVM.filterButtons.buttonReactions.setMode(\.normal)
         feedDetailVM.filterButtons.buttonComments.setMode(\.selected)
         feedDetailVM.filterButtons.send(\.didTapComments)
      case .nothing:
         break
      case .presentLikesScene(let transaction):
         Asset.router?.route(.presentModally(.automatic), scene: \.challengeReactions, payload: ReactionsSceneInput.Transaction(transaction.id))
      }
   }
}
