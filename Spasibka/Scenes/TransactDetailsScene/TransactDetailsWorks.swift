//
//  FeedDetailWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 29.09.2022.
//

import Foundation
import StackNinja

final class FeedDetailWorksTempStorage: InitProtocol {
   var currentUserName = ""
   var currentTransactId: Int?
   var currentFeed: Feed?
   var userLiked: Bool = false
   var token: String?

   var likes: [Like]?

   var inputComment = ""
   var reactionSegment = 0
   var transaction: EventTransaction?

   var comments: [Comment] = []
}

final class TransactDetailsWorks<Asset: AssetProtocol>: BaseWorks<FeedDetailWorksTempStorage, Asset>,
   CurrentUserStorageWorksProtocol, InputTextCachableWorks
{
   private lazy var apiUseCase = Asset.apiUseCase
   private lazy var storeUseCase = Asset.safeStorageUseCase
   
   var loadToken: VoidWork { .init { [weak self] work in
      self?.storeUseCase.loadToken
         .doAsync()
         .onSuccess {
            Self.store.token = $0
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var saveInput: Work<TransactDetailsSceneInput, (EventTransaction, Bool)> { .init { [weak self] work in
      guard let input = work.input else { return }

      switch input {
      case let .feedElement(input):
         Self.store.currentFeed = input
         Self.store.currentTransactId = input.transaction?.id
         Self.store.userLiked = input.transaction?.userLiked ?? false

         if let transactionId = input.transaction?.id {
            self?.inputTextCacher.setKey("TransactDetailsCommentInput \(transactionId)")
            
            self?.getEventsTransactById
               .doAsync(transactionId)
               .onSuccess {
                  Self.store.transaction = $0
                  Self.store.userLiked = $0.userLiked
                  
                  work.success((result: $0, false))
               }
         } else {
            work.fail()
         }
      case let .transactId(transactionId, isComment):
         Self.store.currentTransactId = transactionId

         self?.inputTextCacher.setKey("TransactDetailsCommentInput \(transactionId)")
         
         self?.getEventsTransactById
            .doAsync(transactionId)
            .onSuccess {
               Self.store.transaction = $0
               Self.store.userLiked = $0.userLiked
               if isComment == true { work.success((result: $0, true)) }
               else { work.success((result: $0, false)) }
            }
      }
   }.retainBy(retainer) }

   var getTransaction: Out<EventTransaction> { .init { work in
      guard let transaction = Self.store.transaction else {
         work.fail()
         return
      }
      work.success(result: transaction)
   }}

   var pressLike: Work<Void, Bool> { .init { [weak self] work in
      guard let tId = Self.store.currentTransactId else { work.fail(Self.store.userLiked); return }

      let body = PressLikeRequest.Body(likeKind: 1, transactionId: tId)
      let request = PressLikeRequest(token: "", body: body, index: 0)

      self?.apiUseCase.pressLike
         .doAsync(request)
         .onSuccess {
            if body.likeKind == 1 {
               Self.store.userLiked = !Self.store.userLiked
            } else if body.likeKind == 2 {
               Self.store.userLiked = false
            }
            work.success(result: Self.store.userLiked)
         }
         .onFail {
            work.fail(Self.store.userLiked)
         }
   }.retainBy(retainer) }

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
   }.retainBy(retainer) }

   var getTransactStat: Work<Void, (LikesCommentsStatistics, Bool)> { .init { [weak self] work in
      guard let transactId = Self.store.currentTransactId else { return }
      let body = LikesCommentsStatRequest.Body(transactionId: transactId)
      let request = LikesCommentsStatRequest(token: "", body: body)
      self?.apiUseCase.getLikesCommentsStat
         .doAsync(request)
         .onSuccess {
            let likes = (Self.store.userLiked)
            work.success(result: ($0, likes))
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getComments: Work<Void, [Comment]> { .init { [weak self] work in
      guard let transactId = Self.store.currentTransactId else { return }
      let request = CommentsRequest(token: "",
                                    body: CommentsRequestBody(
                                       transactionId: transactId,
                                       includeName: true,
                                       isReverseOrder: true
                                    ))
      self?.apiUseCase.getComments
         .doAsync(request)
         .onSuccess {
            Self.store.comments = $0
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var updateInputComment: Work<String, String> { .init { work in
      Self.store.inputComment = work.unsafeInput
      work.success(result: work.unsafeInput)
   }.retainBy(retainer) }

   var createComment: Work<Void, Void> { .init { [weak self] work in
      guard
         let token = Self.store.token,
         let id = Self.store.currentTransactId
      else { return }

      let body = CreateCommentBody(transaction: id, text: Self.store.inputComment)
      let request = CreateCommentRequest(token: token, body: body)

      self?.apiUseCase.createComment
         .doAsync(request)
         .onSuccess {
            self?.inputTextCacher.clearCache()
            Self.store.inputComment = ""
            
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var updateComment: Work<UpdateCommentRequest, Void> { .init { [weak self] work in
      guard let input = work.input else { return }
      self?.apiUseCase.updateComment
         .doAsync(input)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

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

   var getLikesByTransaction: Work<Void, Void> { .init { [weak self] work in
      guard
         let transactId = Self.store.currentTransactId
      else { return }

      let request = LikesByTransactRequest(token: "", body: LikesByTransactBody(transactionId: transactId,
                                                                                includeName: true))

      self?.apiUseCase.getLikesByTransaction
         .doAsync(request)
         .onSuccess {
            Self.store.likes = $0
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getAllReactions: Out<[ReactItem]> { .init { work in
      let filtered = Self.filteredAll()
      Self.store.reactionSegment = 0
      work.success(result: filtered)
   }}

   var getLikeReactions: Out<[ReactItem]> { .init { work in
      let filtered = Self.filteredLikes()
      Self.store.reactionSegment = 1
      work.success(result: filtered)
   }}

   var isLikedByMe: Out<Bool> { .init { work in
      let isMyLike = Self.store.userLiked
      work.success(isMyLike)
   }.retainBy(retainer) }

   var getSelectedReactions: Out<[ReactItem]> { .init { work in
      var filtered: [ReactItem] = []
      switch Self.store.reactionSegment {
      case 0:
         filtered = Self.filteredAll()
      case 1:
         filtered = Self.filteredLikes()
      default:
         filtered = Self.filteredAll()
      }
      work.success(result: filtered)
   }}

   var getEventsTransactById: Work<Int, EventTransaction> { .init { [weak self] work in
      guard let id = work.input else { return }
      self?.apiUseCase.getEventsTransactById
         .doAsync(id)
         .onSuccess {
            print($0)
            work.success(result: $0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var updateCommentItem: Work<(PressLikeResult, Int), (Comment, Int)> {
      .init { work in
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
      }
   }

   lazy var inputTextCacher = TextCachableWork(cache: Asset.service.staticTextCache) 
}

private extension TransactDetailsWorks {
   static func filteredAll() -> [ReactItem] {
      guard let likes = store.likes else {
         return []
      }

      var items: [ReactItem] = []
      for like in likes {
         items += like.items ?? []
      }
      return items
   }

   static func filteredLikes() -> [ReactItem] {
      guard let likes = store.likes else {
         return []
      }

      var items: [ReactItem] = []
      for like in likes {
         if like.likeKind?.code == "like" {
            items += like.items ?? []
         }
      }
      return items
   }
}
