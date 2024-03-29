//
//  ChallengeCommentsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

struct ChallengeCommentsScenarioEvents: ScenarioPayloadedEvents {
   let payload = Out<Challenge>()

   let didEditingComment: Out<String>
   let didSendCommentPressed: VoidWork
   let commentLiked: Out<PressLikeRequest>
   let deleteCommentAtIndex: Out<Int>
}

final class ChallengeCommentsScenario<Asset: ASP>: BasePayloadedScenario<ChallengeCommentsScenarioEvents, ChallengeCommentsState, ChallengeCommentsWorks<Asset>> {
   override func configure() {
      super.configure()

      start
         .doNext(works.loadComments)
         .onSuccess(setState) { .presentComments($0) }
         .onFail(setState, .error)

      events.didEditingComment
         .doNext(works.updateInputComment)
         .doNext(works.inputCommentTextCacher)
         .onSuccess(setState) { .updateCommentInput($0) }
         .doNext(IsEmpty())
         .onSuccess(setState, .sendButtonDisabled)
         .onFail(setState, .sendButtonEnabled)

      events.didSendCommentPressed
         .onSuccess(setState, .sendButtonDisabled)
         .doNext(works.createComment)
         .onSuccess(setState, .commentDidSend)
         .onFail { assertionFailure("error sending comment") }
         .doSendVoidEvent(start)

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
         .doNext(works.loadComments)
         .onSuccess(setState) { .presentComments($0) }
         .onFail(setState) { .presentComments([]) }
   }
}
