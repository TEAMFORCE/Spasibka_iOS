//
//  ChallengeDetailsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.10.2022.
//

import StackNinja

struct ChallengeAllResultsEvents: ScenarioEvents {
   let saveInputAndPrepare: Out<ChallengeDetailsInput>
}

final class ChallengeAllResultsScenario<Asset: AssetProtocol>: BaseWorkableScenario<
   ChallengeAllResultsEvents,
   ChallResultsSceneState,
   ChallengeDetailsWorks<Asset>
> {
   private let detailWorks = ChallengeDetailsBlockWorks<Asset>()

   override func configure() {
      super.configure()

      events.saveInputAndPrepare
         .doNext(works.saveInput)
         .onSuccess(setState) {
            switch $0 {
            case let .byChallenge(_, chapter):
               return .presentChapter(chapter)
            case let .byFeed(_, chapter):
               return .presentChapter(chapter)
            case let .byId(_, chapter):
               return .presentChapter(chapter)
            }
         }
         .doVoidNext(works.getChallengeById)
         .onSuccess(setState) {
            .updatePayloadForPages($0)
         }
         .onFail(setState, .error)
         .doVoidNext(works.amIOwnerCheck)
         .onSuccess(setState, .iAmOwner)
         .doAnyway(works.isVotingChallenge)
         .onSuccess(setState, .votingChallenge)
         .doAnyway(works.checkShowCandidates)
         .onSuccess(setState, .enableContenders)
         .doAnyway(works.checkWinnersStatus)
         .onSuccess(setState, .enableWinners)
         .doAnyway(works.amIAdminAndActiveChall)
         .doAnyway(works.getChallengeResult)
         .onSuccess(self) {
            $0.setState(.enableMyResult($1))

//            $0.works.anyReportToPresent
//               .doAsync()
//               .onSuccess($0) {
//                  $0.setState(.presentReportDetailView($1))
//               }
//               .onFail {
//                  print("fail")
//               }
         }
         .onFail(self) {_ in 
//            $0.works.anyReportToPresent
//               .doAsync()
//               .onSuccess($0) {
//                  $0.setState(.presentReportDetailView($1))
//               }
//               .onFail {
//                  print("fail")
//               }
         }
   }
}

struct ChallengeDetailsInputEvents: ScenarioEvents {
   let saveInputAndLoadChallenge: Out<ChallengeDetailsInput>

   let challengeResultDidSend: VoidWork
   let challengeResultDidCancelled: Work<Void, Void>

   let editButtonTapped: VoidWork
   let shareButtonTapped: VoidWork

   let didFinishChallengeOperation: Out<FinishEditChallengeEvent>

   let reactionPressed: VoidWork
   let didTapComments: VoidWork

   let sendChallengeResult: VoidWork
   let didTapAllResults: VoidWork
   let didTapAllReactions: VoidWork

   let loadChallengeByCurrentID = Out<Void>()
}

final class ChallengeDetailsScenario<Asset: AssetProtocol>: BaseWorkableScenario<
   ChallengeDetailsInputEvents,
   ChallengeDetailsState,
   ChallengeDetailsWorks<Asset>
> {
   private let detailWorks = ChallengeDetailsBlockWorks<Asset>()

   override func configure() {
      super.configure()

      events.saveInputAndLoadChallenge
         .onSuccess(setState) { (input: ChallengeDetailsInput) in
            switch input {
            case let .byChallenge(chall, _):
               return .setHeaderImage(chall.photoCache)
            default:
               return .initial
            }
         }
         .doNext(works.saveInput)
         .doMap { $0 }
         .onSuccess(setState) {
            switch $0 {
            case let .byChallenge(_, chapter):
               return .presentChapter(chapter)
            case let .byFeed(_, chapter):
               return .presentChapter(chapter)
            case let .byId(_, chapter):
               return .presentChapter(chapter)
            }
         }
         .doSendVoidEvent(events.loadChallengeByCurrentID)

      events.loadChallengeByCurrentID
         .doNext(works.getChallengeById)
         .onSuccess(setState) {
            .updatePayloadForPages($0)
         }
         .onFail(setState, .error)
         .doVoidNext(works.amIOwnerCheck)
         .onSuccess(setState, .iAmOwner)
         .doAnyway(works.isVotingChallenge)
         .onSuccess(setState, .votingChallenge)
         .doAnyway(works.checkShowCandidates)
         .onSuccess(setState, .enableContenders)
         .doAnyway(works.checkWinnersStatus)
         .onSuccess(setState, .enableWinners)
         .doAnyway(works.amIAdminAndActiveChall)
         .onSuccess(setState, .activateEditButton)
         .doAnyway(works.getChallengeResult)
         .onSuccess(self) {
            $0.setState(.enableMyResult($1))

            $0.works.anyReportToPresent
               .doAsync()
               .onSuccess($0) {
                  $0.setState(.presentReportDetailView($1))
               }
               .onFail {
                  print("fail")
               }
         }
         .onFail(self) {
            $0.works.anyReportToPresent
               .doAsync()
               .onSuccess($0) {
                  $0.setState(.presentReportDetailView($1))
               }
               .onFail {
                  print("fail")
               }
         }

      events.sendChallengeResult
         .doNext(works.getChallenge)
         .onSuccess(setState) {
            .presentSendResultScreen($0)
         }

      events.challengeResultDidSend
         .doSendEvent(events.loadChallengeByCurrentID)

      events.challengeResultDidCancelled
         .onSuccess(setState, .challengeResultDidCancelled)

      events.editButtonTapped
         .doNext(works.getChallenge)
         .onSuccess(setState) { .presentChallengeEdit($0) }
         .onFail {
            print("fail")
         }

      events.shareButtonTapped
         .doNext(works.getLinkToShare)
         .onSuccess(setState) { .presentShareView($0) }
         .onFail {
            print("fail get link to share")
         }

      events.didFinishChallengeOperation
         .onSuccess(self) {
            switch $1 {
            case .didCreate, .didEdit:
               $0.events.loadChallengeByCurrentID.sendAsyncEvent()
            case .didDelete:
               $0.setState(.challengeDeleted)
            }
         }

      events.reactionPressed
         .doNext(detailWorks.isLikedByMe)
         .onSuccess(setState) { .buttonLikePressed(alreadySelected: !$0) }
         .doVoidNext(detailWorks.pressLike)
         .onFail(setState) { .failedToReact(alreadySelected: $0) }
         .onSuccess(setState) { .buttonLikePressed(alreadySelected: $0) }
         .doVoidNext(detailWorks.getLikesAmount)
         .onSuccess(setState) { .updateLikesAmount($0) }

      events.didTapComments
         .doNext(works.getChallenge)
         .onSuccess(setState) { .presentComments($0) }

      events.didTapAllResults
         .doNext(works.getInput)
         .onSuccess(setState) { .presentAllResults($0) }

      events.didTapAllReactions
         .doNext(works.getChallenge)
         .onSuccess(setState) { .presentAllReactions($0) }
   }
}
