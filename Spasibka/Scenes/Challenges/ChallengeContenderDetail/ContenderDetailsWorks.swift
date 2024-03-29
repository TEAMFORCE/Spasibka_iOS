//
//  ChallCandidateDetailsWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.12.2022.
//

import Foundation
import StackNinja

final class ContenderDetailWorksTempStorage: InitProtocol {
   var contender: Contender?
   var reportId: Int?
   var userLiked: Bool = false
   var likesAmount: Int = 0
   var inputComment = ""
   
   var winnerReport: ChallengeReport?
   var winnerReportId: Int?
   
   var comments: [Comment] = []
}

final class ContenderDetailsWorks<Asset: AssetProtocol>: BaseWorks<ContenderDetailWorksTempStorage, Asset>,
   CurrentUserStorageWorksProtocol
{
   private lazy var apiUseCase = Asset.apiUseCase
   private lazy var storeUseCase = Asset.safeStorageUseCase
   
   var saveInput: Work<ContenderDetailsSceneInput, (ContenderDetailsSceneInput, Bool)> { .init { [weak self] work in
      guard let input = work.input else { work.fail(); return }
      switch input {
      case .contender(let contender):
         Self.store.contender = contender
         Self.store.reportId = contender.reportId
         Self.store.userLiked = contender.userLiked ?? false
         work.success((input, false))
      case .winnerReportId(let id, let isComment):
         self?.getChallengeReportById
            .doAsync(id)
            .onSuccess {
               Self.store.winnerReport = $0
               Self.store.winnerReportId = id
               Self.store.userLiked = $0.userLiked ?? false
               let res = ContenderDetailsSceneInput.winnerReport($0)
               
               if isComment == true {
                  work.success((res, true))
               } else {
                  work.success((res, false))
               }
            }
            .onFail { work.fail() }
      case .winnerReport(_):
         work.success((input, false))
         break
      }
      
     // work.success(input)
   }.retainBy(retainer) }
   
   var getLikesByContender: Out<[ReactItem]> { .init { [weak self] work in
      // input 1 for likes
      // input 2 for dislikes
      let id: Int? = Self.store.reportId != nil ? Self.store.reportId : Self.store.winnerReportId
      
      let request = LikesRequestBody(challengeReportId: id,
                                     likeKind: 1,
                                     includeName: true)
      
      self?.apiUseCase.getLikes
         .doAsync(request)
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var getComments: Work<Void, [Comment]> { .init { [weak self] work in
      let id: Int? = Self.store.reportId != nil ? Self.store.reportId : Self.store.winnerReportId
      
      
      let request = CommentsRequest(token: "",
                                    body: CommentsRequestBody(
                                       challengeReportId: id,
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
   
   var getContenderOrWinner: Work<Void, ContenderDetailsSceneInput> { .init { work in
      //guard let contender = Self.store.contender else { work.fail(); return }
      if let contender = Self.store.contender {
         work.success(ContenderDetailsSceneInput.contender(contender))
         return
      }
      if let winner = Self.store.winnerReport {
         work.success(ContenderDetailsSceneInput.winnerReport(winner))
         return
      }
      work.fail()
   }.retainBy(retainer) }
   
   var getContenderOrWinnerReportId: Work<Void, Int> { .init { work in
      if let contender = Self.store.contender {
         work.success(contender.reportId)
         return
      }
      if let winnerId = Self.store.winnerReportId {
         work.success(winnerId)
         return
      }
      work.fail()
   }.retainBy(retainer) }
   
   var isLikedByMe: Out<Bool> { .init { work in
      work.success(Self.store.userLiked)
   }.retainBy(retainer) }
   
   var pressLike: Work<Void, Bool> { .init { [weak self] work in
      guard let reportId = Self.store.reportId != nil ? Self.store.reportId :
               Self.store.winnerReportId else {
         work.fail(Self.store.userLiked)
         return
      }
      
      let body = PressLikeRequest.Body(likeKind: 1, challengeReportId: reportId)
      let request = PressLikeRequest(token: "", body: body, index: 0)
      
      self?.apiUseCase.pressLike
         .doAsync(request)
         .onSuccess {
            if body.likeKind == 1 {
               Self.store.userLiked = !Self.store.userLiked
               Self.store.likesAmount = $0.likesAmount ?? 0
               //               Self.store.userDisliked = false
            } else if body.likeKind == 2 {
               //               Self.store.userDisliked = !Self.store.userDisliked
               Self.store.userLiked = false
            }
            work.success(result: Self.store.userLiked)
         }
         .onFail {
            work.fail(Self.store.userLiked)
         }
   }.retainBy(retainer) }
   
   var getLikesAmountFromStore: Work<Void, Int> { .init { work in
      work.success(Self.store.likesAmount)
   }.retainBy(retainer) }
   
   var updateInputComment: Work<String, String> { .init { work in
      Self.store.inputComment = work.unsafeInput
      work.success(result: work.unsafeInput)
   }.retainBy(retainer) }
   
   var createComment: Work<Void, Void> { .init { [weak self] work in
      guard let id = Self.store.reportId != nil ? Self.store.reportId :
               Self.store.winnerReportId  else { work.fail(); return }

      let body = CreateCommentBody(challengeReportId: id,
                                   text: Self.store.inputComment)
      let request = CreateCommentRequest(token: "", body: body)

      self?.apiUseCase.createComment
         .doAsync(request)
         .onSuccess {
            work.success()
            Self.store.inputComment = ""
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   var getChallengeReportById: Work<Int, ChallengeReport> { .init { [weak self] work in
      guard let id = work.input else { return }
      self?.apiUseCase.getChallengeReport
         .doAsync(id)
         .onSuccess {
            work.success(result: $0)
         }
         .onFail {
            work.fail()
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
