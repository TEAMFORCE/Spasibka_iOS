//
//  ChallengeDetailsBlockWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.09.2023.
//

import StackNinja

final class ChallengeDetailsBlockStore: PayloadWorkStore {
   var payload: Challenge?
   
   var userLiked: Bool? = nil
}

final class ChallengeDetailsBlockWorks<Asset: ASP>: BasePayloadWorks<ChallengeDetailsBlockStore, Asset>, ApiUseCaseable {
   let apiUseCase = Asset.apiUseCase
}

extension ChallengeDetailsBlockWorks {
   var getChallenge: Work<Void, Challenge> { .init { work in
      guard let challenge = Self.store.payload else { work.fail(); return }
      Self.store.userLiked = challenge.userLiked
      work.success(challenge)
   }.retainBy(retainer) }
   
   var getCreatorId: Work<Void, Int> { .init { work in
      guard let id = Self.store.payload?.creatorId else { return }
      work.success(id)
   } }
   
   var isLikedByMe: Out<Bool> { .init { work in
      guard let isMyLike = Self.store.userLiked else { work.fail(); return }
      work.success(isMyLike)
   }.retainBy(retainer) }
   
   var pressLike: Work<Void, Bool> { .init { [weak self] work in
      guard
         let id = Self.store.payload?.id,
         let userLiked = Self.store.userLiked
      else { work.fail(); return }
      
      let body = PressLikeRequest.Body(likeKind: 1, challengeId: id)
      let request = PressLikeRequest(token: "", body: body, index: 1)
      self?.apiUseCase.pressLike
         .doAsync(request)
         .onSuccess {
            Self.store.userLiked = !userLiked
            work.success(Self.store.userLiked ?? false)
         }
         .onFail {
            work.fail(Self.store.userLiked)
         }
   } }
   
   var getLikesAmount: Work<Void, Int> { .init { [weak self] work in
      guard let id = Self.store.payload?.id else { work.fail(); return }
      let body = LikesCommentsStatRequest.Body(challengeId: id)
      let request = LikesCommentsStatRequest(token: "", body: body)
      self?.apiUseCase.getLikesCommentsStat
         .doAsync(request)
         .onSuccess {
            var amount = 0
            if let reactions = $0.likes {
               for reaction in reactions {
                  if reaction.likeKind?.code == "like" {
                     amount = reaction.counter ?? 0
                  }
               }
            }
            work.success(result: amount)
         }
         .onFail {
            work.fail()
         }
   } }
}
