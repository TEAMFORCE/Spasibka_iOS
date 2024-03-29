//
//  ChallengeDetailsWorks+Checks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 15.11.2022.
//

import StackNinja

extension ChallengeDetailsWorks {
   var amIOwnerCheck: Work<Void, Void> { .init { work in
      guard
         let profileId = Self.store.currentProfileId,
         let creatorId = Self.store.challenge?.creatorId
      else { work.fail(); return }

      if profileId == creatorId {
         work.success(())
      } else {
         work.fail()
      }
   }.retainBy(retainer) }

   var amIAdminAndActiveChall: Work<Void, Void> { .init { work in
      guard
         let role = Self.store.currentUserRole
      else { work.fail(); return }
      if role == "A", Self.store.challenge?.active == true {
         work.success()
      } else {
         work.fail()
      }
   }.retainBy(retainer) }

   var isVotingChallenge: Work<Void, Void> { .init { work in
      guard let challenge = Self.store.challenge else {
         work.fail()
         return
      }
      if challenge.algorithmType == 2 {
         work.success()
      } else {
         work.fail()
      }
   }.retainBy(retainer) }

   var checkShowCandidates: Work<Void, Void> { .init { work in
      guard let challenge = Self.store.challenge else {
         work.fail()
         return
      }
      challenge.showContenders == true ? work.success() : work.fail()
   }.retainBy(retainer) }

   var checkWinnersStatus: Work<Void, Void> { .init { work in
      guard let challenge = Self.store.challenge else {
         work.fail()
         return
      }
      challenge.approvedReportsAmount > 0 ? work.success() : work.fail()
   }.retainBy(retainer) }
}
