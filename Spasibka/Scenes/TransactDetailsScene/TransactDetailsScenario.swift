//
//  FeedDetailScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 28.09.2022.
//

import StackNinja
import UIKit

import StackNinja
import UIKit

struct FeedDetailEvents: ScenarioEvents {   
   let presentDetails: Out<Void>
   let presentComment: Out<Void>
   let presentReactions: Out<Void>
   let reactionPressed: Out<Void>
   let userAvatarPressed: Out<Int>

   let saveInput: Out<TransactDetailsSceneInput>

   let didEditingComment: Out<String>
   let didSendCommentPressed: VoidWork

   let presentAllReactions: Out<Void>
   let presentLikeReactions: Out<Void>
   
   let commentLiked: Out<PressLikeRequest>
   
   let presentProfile: Out<Int>
   let deleteCommentAtIndex: Out<Int>
   
   let presentLikesScene: VoidWork
}

final class TransactDetailsScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<FeedDetailEvents, FeedDetailSceneState, TransactDetailsWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()
      
      start
         .doNext(works.loadToken)
         .onFail(setState, .error)

      events.reactionPressed
         .doNext(works.isLikedByMe)
         .onSuccess(setState) { .buttonLikePressed(alreadySelected: $0) }
         .doVoidNext(works.pressLike)
         .onFail(setState) { .failedToReact(alreadySelected: $0) }
         .doVoidNext(works.getTransactStat)
         .onSuccess(setState) { .updateReactions($0) }

      events.saveInput
         .doSaveResult()
         .doVoidNext(works.getCurrentUserName)
         .onSuccessMixSaved(setState) { (userName: String, input: TransactDetailsSceneInput) in
            switch input {
            case .feedElement(let feed):
               return .present(feed: feed, currentUsername: userName)
            case .transactId:
               return .initial
            }
         }
         .doLoadResult()
         .doNext(works.saveInput)
         .doSaveResult()
         .doVoidNext(works.getCurrentUserName)
         .onSuccessMixSaved(setState) {
            (userName: String, transaction: (EventTransaction, Bool)) in
               .presentDetails(transaction: transaction.0, currentUsername: userName)
         }
         .onSuccessMixSaved(setState) {
            (userName: String, transaction: (EventTransaction, Bool)) in
            if transaction.1 == true { return .sendCommentEvent }
            else { return .nothing }
         }
         .doVoidNext(works.getComments)
         .onSuccess(setState) { .presentComments($0) }
         .onFail(setState) { .presentComments([]) }
      

      events.presentDetails
         .doCancel(events.presentComment, events.presentReactions)
         .onSuccess(setState, .presntActivityIndicator)
         .doNext(works.getTransaction)
         .doSaveResult()
         .doVoidNext(works.getCurrentUserName)
         .onSuccessMixSaved(setState) {
            (userName: String, transaction: EventTransaction) in
               .presentDetails(transaction: transaction, currentUsername: userName)
         }

      events.presentComment
         .doCancel(events.presentDetails, events.presentReactions)
//         .onSuccess(setState, .presntActivityIndicator)
         .doNext(works.getComments)
         .onSuccess(setState) { .presentComments($0) }
         .onFail(setState) { .presentComments([]) }

      events.presentReactions
         .doCancel(events.presentDetails, events.presentComment)
         .onSuccess(setState, .presntActivityIndicator)
         .doNext(works.getLikesByTransaction)
         .doNext(works.getSelectedReactions)
         .onSuccess(setState) {
            if $0.isEmpty {
               return .hereIsEmpty
            }
            return .presentReactions($0)
         }
         .onFail {
            print("failed to present reactions")
         }

      events.presentAllReactions
         .onSuccess(setState, .presntActivityIndicator)
         .doNext(works.getAllReactions)
         .onSuccess(setState) { .presentReactions($0) }
         .onFail {
            print("failed to present reactions")
         }

      events.presentLikeReactions
         .onSuccess(setState, .presntActivityIndicator)
         .doNext(works.getLikeReactions)
         .onSuccess(setState) { .presentReactions($0) }
         .onFail {
            print("failed to present reactions")
         }

      events.didEditingComment
         .doNext(works.updateInputComment)
         .doNext(works.inputTextCacher)
         .onSuccess(setState) { .updateCommentInputField($0) }
         .doNext(IsEmpty())
         .onSuccess(setState, .sendButtonDisabled)
         .onFail(setState, .sendButtonEnabled)

      events.didSendCommentPressed
         .onSuccess(setState, .sendButtonDisabled)
         .doNext(works.createComment)
         .onSuccess(setState, .commentDidSend)
         .onFail(setState, .error)

      events.userAvatarPressed
         .onSuccess(setState) { .presentUserProfile($0) }
      
      events.presentProfile
         .onSuccess(setState) { .presentUserProfile($0) }
      
      events.commentLiked
         .doNext(works.pressLikeComment)
         .onSuccess {
            $0
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
         .doNext(works.getTransaction)
         .onSuccess(setState) { .presentLikesScene($0) }
   }
}
