//
//  ChallengeCommentsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

final class ChallengeCommentsStore: PayloadWorkStore {
   var payload: Challenge?

   var comments: [Comment] = []
   var inputComment: String = ""
}

final class ChallengeCommentsWorks<Asset: ASP>: BasePayloadWorks<ChallengeCommentsStore, Asset>, ApiUseCaseable {
   let apiUseCase = Asset.apiUseCase

   private(set) lazy var inputCommentTextCacher = TextCachableWork(
      cache: Asset.service.staticTextCache,
      key: "chall_comment_cache_key"
   )
   
   var loadComments: Work<Void, [Comment]> { .init { [weak self] work in
      guard let challengeId = Self.store.payload?.id else { return }
     
      let request = CommentsRequest(
         token: "",
         body: CommentsRequestBody(
            challengeId: challengeId,
            includeName: true,
            isReverseOrder: true
         )
      )
      self?.apiUseCase.getComments
         .doAsync(request)
         .onSuccess {
            Self.store.comments = $0
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   } }

   var updateInputComment: Work<String, String> { .init { work in
      Self.store.inputComment = work.unsafeInput
      work.success(result: work.unsafeInput)
   } }

   var pressLikeComment: Work<PressLikeRequest, PressLikeResult> { .init { [weak self] work in
      guard let input = work.input else { work.fail(); return }

      self?.apiUseCase.pressLike
         .doAsync(input)
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   } }

   var updateCommentItem: Work<(PressLikeResult, Int), (Comment, Int)> { .init { work in
      guard
         let likeResult = work.input?.0,
         let index = work.input?.1
      else {
         work.fail()
         return
      }
      if Self.store.comments.indices.contains(index) {
         var item = Self.store.comments[index]
         item.update(likesAmount: likeResult.likesAmount ?? 0,
                     userLiked: likeResult.isLiked ?? false)
         Self.store.comments[index] = item
         work.success((item, index))
      } else {
         work.fail()
      }
   } }

   var createComment: Work<Void, Void> { .init { [weak self] work in
      guard
         let id = Self.store.payload?.id
      else { return }

      let body = CreateCommentBody(challengeId: id, text: Self.store.inputComment)
      let request = CreateCommentRequest(token: "", body: body)

      self?.apiUseCase.createComment
         .doAsync(request)
         .onSuccess {
            Self.store.inputComment = ""
            self?.inputCommentTextCacher.clearCache()

            work.success()
         }
         .onFail {
            work.fail()
         }
   } }
   
   var deleteComment: Work<Int, Void> { .init { [weak self] work in
      guard
         let input = work.input,
         let comment = Self.store.comments[safe: input]
      else {
         work.fail(); return
      }
      self?.apiUseCase.deleteComment
         .doAsync(RequestWithId(token: "", id: comment.id))
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
}
