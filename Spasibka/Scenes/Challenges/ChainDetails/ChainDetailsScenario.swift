//
//  ChainDetailsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.10.2022.
//

import StackNinja

struct ChainDetailsInputEvents: ScenarioPayloadedEvents {
   let payload: Out<ChainDetailsInput>
   
   let updateChainDetails: Out<ChallengeGroup>
}

final class ChainDetailsScenario<Asset: AssetProtocol>: BaseWorkableScenario<
   ChainDetailsInputEvents,
   ChainDetailsState,
   ChainDetailsWorks<Asset>>
{
   override func configure() {
      super.configure()

      events.payload
         .doNext(works.storePayload)
         .doVoidNext(works.getChain)
         .onSuccess(setState) { .updateChainDetails($0) }
      
      events.updateChainDetails
         .doMap(works.setChainDetails)
         .doVoidNext(works.getChain)
         .onSuccess(setState) { .updatePayload($0) }
      
//      events.saveInputAndLoadChallenge
//         .onSuccess(setState) { (input: ChainDetailsInput) in
//            switch input {
//            case let .byChallenge(chall, _):
//               return .setHeaderImage(chall.photoCache)
//            default:
//               return .initial
//            }
//         }
//         .doNext(works.saveInput)
//         .doMap { $0 }
//         .onSuccess(setState) {
//            switch $0 {
//            case let .byChallenge(_, chapter):
//               return .presentChapter(chapter)
//            case let .byFeed(_, chapter):
//               return .presentChapter(chapter)
//            case let .byId(_, chapter):
//               return .presentChapter(chapter)
//            }
//         }
//         .doSendVoidEvent(events.loadChallengeByCurrentID)
//
//      events.loadChallengeByCurrentID
//         .doNext(works.getChallengeById)
//         .onSuccess(setState) {
//            .updatePayloadForPages($0)
//         }
//         .onFail(setState, .error)
//         .doVoidNext(works.amIOwnerCheck)
//         .onSuccess(setState, .iAmOwner)
//         .doAnyway(works.isVotingChallenge)
//         .onSuccess(setState, .votingChallenge)
//         .doAnyway(works.checkShowCandidates)
//         .onSuccess(setState, .enableContenders)
//         .doAnyway(works.checkWinnersStatus)
//         .onSuccess(setState, .enableWinners)
//         .doAnyway(works.amIAdminAndActiveChall)
//         .onSuccess(setState, .activateEditButton)
//         .doAnyway(works.getChallengeResult)
//         .onSuccess(self) {
//            $0.setState(.enableMyResult($1))
//
//            $0.works.anyReportToPresent
//               .doAsync()
//               .onSuccess($0) {
//                  $0.setState(.presentReportDetailView($1))
//               }
//               .onFail {
//                  print("fail")
//               }
//         }
//         .onFail(self) {
//            $0.works.anyReportToPresent
//               .doAsync()
//               .onSuccess($0) {
//                  $0.setState(.presentReportDetailView($1))
//               }
//               .onFail {
//                  print("fail")
//               }
//         }
//
//      events.challengeResultDidSend
//         .onSuccess(setState, .resultSentSuccessfully)
//
//      events.challengeResultDidCancelled
//         .onSuccess(setState, .challengeResultDidCancelled)
//
//      events.editButtonTapped
//         .doNext(works.getChallenge)
//         .onSuccess(setState) { .presentChallengeEdit($0) }
//         .onFail {
//            print("fail")
//         }
//
//      events.shareButtonTapped
//         .doNext(works.getLinkToShare)
//         .onSuccess(setState) { .presentShareView($0) }
//         .onFail {
//            print("fail get link to share")
//         }
//
//      events.didFinishChallengeOperation
//         .onSuccess(self) {
//            switch $1 {
//            case .didCreate, .didEdit:
//               $0.events.loadChallengeByCurrentID.sendAsyncEvent()
//            case .didDelete:
//               $0.setState(.challengeDeleted)
//            }
//         }
   }
}
