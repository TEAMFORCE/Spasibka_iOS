//
//  ChallCandidateDetailsScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.12.2022.
//

import StackNinja
import UIKit

struct ContenderDetailEvents: ScenarioEvents {   
   let saveInput: Out<ContenderDetailsSceneInput>
   let presentReactions: Out<Void>
   let presentComment: Out<Void>
   let presentDetails: Out<Void>
   let reactionPressed: Out<Void>
   let userAvatarPressed: Out<Int>
   
   let didEditingComment: Out<String>
   let didSendCommentPressed: VoidWork
   
   let commentLiked: Out<PressLikeRequest>
   let deleteCommentAtIndex: Out<Int>
   
   let presentLikesScene: VoidWork
}

final class ContenderDetailsScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<ContenderDetailEvents, ContenderDetailSceneState, ContenderDetailsWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()
      
      events.saveInput
         .doNext(works.saveInput)
         .onSuccess(setState) { .presentContender($0.0) }
         .onSuccess(setState) {
            if $0.1 == false { return .presentContender($0.0) }
            else { return .sendCommentEvent }
         }
         .onFail {
            print("fail")
         }
      
      events.presentReactions
         .doCancel(events.presentDetails, events.presentComment)
         .onSuccess(setState, .presentActivityIndicator)
         .doNext(works.getLikesByContender)
         .onSuccess(setState) {
            if $0.isEmpty {
               return .hereIsEmpty
            }
            return .presentReactions($0)
         }
         .onFail {
            print("failed to present reactions")
         }
      
      events.presentComment
         .doCancel(events.presentDetails, events.presentReactions)
         .onSuccess(setState, .presentActivityIndicator)
         .doNext(works.getComments)
         .onSuccess(setState) { .presentComments($0) }
         .onFail(setState) { .presentComments([]) }
      
      events.presentDetails
         .doCancel(events.presentComment, events.presentReactions)
         .onSuccess(setState, .presentActivityIndicator)
         .doNext(works.getContenderOrWinner)
         .onSuccess(setState) { .presentContender($0) }
      
      events.reactionPressed
         .doNext(works.isLikedByMe)
         .onSuccess(setState) { .buttonLikePressed(alreadySelected: $0) }
         .doVoidNext(works.pressLike)
         .onFail(setState) { .failedToReact(alreadySelected: $0) }
         .doVoidNext(works.getLikesAmountFromStore)
         .onSuccess(setState) { .updateLikesAmount($0) }
      
      events.userAvatarPressed
         .onSuccess(setState) { .presentUserProfile($0) }
      
      events.didEditingComment
         .doNext(works.updateInputComment)
         .doNext(IsEmpty())
         .onSuccess(setState, .sendButtonDisabled)
         .onFail(setState, .sendButtonEnabled)

      events.didSendCommentPressed
         .onSuccess(setState, .sendButtonDisabled)
         .doNext(works.createComment)
         .onSuccess(setState, .commentDidSend)
         .onFail(setState, .error)
      
      events.commentLiked
         .doNext(works.pressLikeComment)
         .onSuccess {
            print($0)
         }
         .doMap { [weak self] stat in
            let index = self?.events.commentLiked.result?.index ?? 0
            let res = (stat, index)
            return res
         }
         .doNext(works.updateCommentItem)
         .onSuccess(setState) {
            .updateCommentAtIndex($0.0, $0.1)
         }
         .onFail {
            print("fail")
         }
      
      events.deleteCommentAtIndex
         .doNext(works.deleteComment)
         .doNext(works.getComments)
         .onSuccess(setState) { .presentComments($0) }
         .onFail(setState) { .presentComments([]) }
      
      events.presentLikesScene
         .doNext(works.getContenderOrWinnerReportId)
         .onSuccess(setState) { .presentLikesScene($0) }
   }
}
