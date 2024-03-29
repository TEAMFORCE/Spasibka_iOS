//
//  ChallCandidateDetailsScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.12.2022.
//

import StackNinja
import UIKit

enum ContenderDetailsSceneInput {
   case contender(Contender)
   case winnerReportId(Int, Bool? = nil)
   case winnerReport(ChallengeReport)
}

final class ContenderDetailsScene<Asset: AssetProtocol>:
   BaseSceneModel<
      DefaultVCModel,
      NavbarBodyStack<Asset, PresentPush>,
      Asset,
      ContenderDetailsSceneInput,
      Void
   >, Scenarible
{
   typealias State = ViewState
   typealias State2 = StackState

   private lazy var contenderDetailVM = ContenderDetailViewModels<Asset>()

   lazy var scenario = ContenderDetailsScenario<Asset>(
      works: ContenderDetailsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: ContenderDetailEvents(
         saveInput: on(\.input),
         presentReactions: contenderDetailVM.filterButtons.on(\.didTapReactions),
         presentComment: contenderDetailVM.filterButtons.on(\.didTapComments),
         presentDetails: contenderDetailVM.filterButtons.on(\.didTapDetails),
         reactionPressed: contenderDetailVM.infoBlock.on(\.reactionPressed),
         userAvatarPressed: contenderDetailVM.infoBlock.on(\.userAvatarPressed),
         didEditingComment: contenderDetailVM.commentsBlock.commentPanelModel.subModel.models.main.on(\.didEditingChanged),
         didSendCommentPressed: contenderDetailVM.commentsBlock.commentPanelModel.subModel.models.right.on(\.didTap),
         commentLiked: contenderDetailVM.commentsBlock.presenter.on(\.reactionPressed),
         deleteCommentAtIndex: contenderDetailVM.commentsBlock.commentTableModel.on(\.deleteItemAtIndex),
         presentLikesScene: contenderDetailVM.detailsBlock.likesAmountLabel.on(\.didTap)
      ))

   override func start() {
      mainVM.navBar.titleLabel.text(Design.text.report)

      configure()
   }

   private var state = ContenderDetailSceneState.initial

   private func configure() {
      mainVM.bodyStack
//         .set(Design.state.stack.brandShiftedBodyStack)
//         .safeAreaOffsetDisabled()
         .alignment(.fill)
         .distribution(.fill)
         .set(.backColor(Design.color.background))
         .arrangedModels([
            contenderDetailVM
         ])

      setState(.initial)
      scenario.configureAndStart()
      
      vcModel?.on(\.viewWillDissappear, self) {
         $0.finishSucces()
      }
   }
}

enum ContenderDetailSceneState {
   case initial
   case presentContender(ContenderDetailsSceneInput)
   case presentActivityIndicator
   case hereIsEmpty
   case presentReactions([ReactItem])
   case presentComments([Comment])
   
   case buttonLikePressed(alreadySelected: Bool)
   case failedToReact(alreadySelected: Bool)
   case updateLikesAmount(Int)
   case presentUserProfile(Int)
   
   case sendButtonDisabled
   case sendButtonEnabled
   case commentDidSend
   
   case updateCommentAtIndex(Comment, Int)
   case sendCommentEvent
   
   case error
   
   case presentLikesScene(Int)
}

extension ContenderDetailsScene: StateMachine {
   func setState(_ state: ContenderDetailSceneState) {
      self.state = state
      switch state {
      case .initial:
         break
         
      case .presentContender(let value):
         contenderDetailVM.setState(.initial(value))
      case .presentActivityIndicator:
         contenderDetailVM.setState(.loadingActivity)
      case .hereIsEmpty:
         contenderDetailVM.setState(.hereIsEmpty)
      case .presentReactions(let items):
         contenderDetailVM.setState(.reactions(items))
      case .presentComments(let comments):
         contenderDetailVM.setState(.comments(comments))
      case .buttonLikePressed(let selected):
         if selected {
            contenderDetailVM.infoBlock.likeButton.setState(.none)
         } else {
            contenderDetailVM.infoBlock.likeButton.setState(.selected)
         }
      case .failedToReact(let selected):
         print("failed to like")
         setState(.buttonLikePressed(alreadySelected: !selected))
      case .updateLikesAmount(let value):
         contenderDetailVM.detailsBlock.likesAmountLabel.text(Design.text.liked + " " + String(value))
      case .presentUserProfile(let userId):
         Asset.router?.route(.push, scene: \.profile, payload: userId)
      case .sendButtonDisabled:
         contenderDetailVM.setState(.sendButtonDisabled)
      case .sendButtonEnabled:
         contenderDetailVM.setState(.sendButtonEnabled)
      case .commentDidSend:
         contenderDetailVM.filterButtons.send(\.didTapComments)
         contenderDetailVM.setState(.commentDidSend)
         
      case .updateCommentAtIndex(let value, let index):
         contenderDetailVM.commentsBlock.commentTableModel.updateItemAtIndex(value, index: index)
      case .sendCommentEvent:
         contenderDetailVM.filterButtons.buttonReactions.setMode(\.normal)
         contenderDetailVM.filterButtons.buttonDetails.setMode(\.normal)
         contenderDetailVM.filterButtons.buttonComments.setMode(\.selected)
         contenderDetailVM.filterButtons.send(\.didTapComments)
      case .error:
         print("Error")
         break
      case .presentLikesScene(let value):
         Asset.router?.route(.presentModally(.automatic), scene: \.challengeReactions, payload: ReactionsSceneInput.ReportId(value))
         
      }
   }
}
