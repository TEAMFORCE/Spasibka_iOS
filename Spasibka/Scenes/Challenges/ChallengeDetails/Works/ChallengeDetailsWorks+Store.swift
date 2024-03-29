//
//  ChallengeDetailsStoreWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 15.11.2022.
//

import StackNinja

extension ChallengeDetailsWorks {
   var saveInput: Work<ChallengeDetailsInput, ChallengeDetailsInput> { .init { [weak self] work in
      guard let self, let input = work.input else { return }

      Self.store.challengeDetailsInput = input

      self.saveCurrentUserData
         .doAsync()
         .onSuccess {
            switch input {
            case .byChallenge(let challenge, _):
               Self.store.challengeId = challenge.id
               work.success(input)
            case .byFeed(let some, _):
               switch some.objectSelector {
               case "Q":
                  guard
                     let challengeId = some.challenge?.id
                  else { work.fail(); return }

                  Self.store.challengeId = challengeId
                  work.success(input)
               case "R":
                  guard
                     let reportId = some.winner?.id,
                     let challengeId = some.winner?.challengeId
                  else { work.fail(); return }

                  Self.store.reportId = reportId
                  Self.store.challengeId = challengeId
                  work.success(input)
               default:
                  work.fail()
               }
            case .byId(let id, _):
               Self.store.challengeId = id
               work.success(input)
            }
         }
   }.retainBy(retainer) }

   var getInput: Out<ChallengeDetailsInput> { .init { work in
      guard let input = Self.store.challengeDetailsInput else {
         work.fail()
         return
      }

      work.success(input)
   }}

   var saveCurrentUserData: Work<Void, Void> { .init { [weak self] work in
      guard let self else { work.fail(); return }

      self.storageUseCase.getCurrentUserName
         .doAsync()
         .onSuccess {
            Self.store.currentUserName = $0
         }
         .doVoidNext(self.storageUseCase.getCurrentUserId)
         .onSuccess {
            Self.store.currentUserId = Int($0)
         }
         .doVoidNext(self.storageUseCase.getCurrentProfileId)
         .onSuccess {
            Self.store.currentProfileId = Int($0)
         }
         .doVoidNext(self.storageUseCase.getCurrentUserRole)
         .onSuccess {
            Self.store.currentUserRole = $0
            work.success()
         }
   }.retainBy(retainer) }
}

extension ChallengeDetailsWorks {
   var getChallengeId: Work<Void, Int> { .init { work in
      guard let id = Self.store.challengeId else { return }
      work.success(id)
   } }

   var getChallenge: Work<Void, Challenge> { .init { work in
      guard let challenge = Self.store.challenge else { return }
      work.success(challenge)
   } }

   var getProfileId: Work<Void, Int> { .init { work in
      guard let id = Self.store.currentUserId else { return }
      work.success(id)
   } }

   var getCreatorId: Work<Void, Int> { .init { work in
      guard let id = Self.store.challenge?.creatorId else { return }
      work.success(id)
   } }
}
