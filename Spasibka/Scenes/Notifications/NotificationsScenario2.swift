//
//  NotificationsScenario2.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 15.11.2022.
//

import StackNinja

struct NotificationsDetailsEvents: ScenarioEvents {   
   let didSelectIndex: Out<Int>
}

final class NotificationsDetailsScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<NotificationsDetailsEvents, FeedDetailsRouterState, NotificationsWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()
      
      events.didSelectIndex
         .doNext(works.getNotificationByIndex)
         .onSuccess(setState) {
            switch $0.type {
            case .transactAdded:
               guard let transaction = NotificationToTransaction.convert($0) else {
                  return .presentNothing
               }
               
               return .presentSentTransactDetails(transaction, navType: .presentModally(.automatic))
            case .challengeCreated:
               guard let challData = NotificationToChallengeDetailsData.convert($0) else {
                  return .presentNothing
               }
               return .presentDetails(.challenge(.byId(challData.id)))
            case .commentAdded:
               guard let commentData = $0.commentData else {
                  return .presentNothing
               }

               if let id = commentData.transactionId {
                  return  .presentDetails(.transaction(.transactId(id)))
               } else if let id = commentData.challengeId {
                  return .presentDetails(.challenge(.byId(id)))
               }
            case .likeAdded:
               guard let likeData = $0.likeData else {
                  return .presentNothing
               }

               if let id = likeData.transactionId {
                  return .presentDetails(.transaction(.transactId(id)))
               } else if let id = likeData.challengeId {
                  return  .presentDetails(.challenge(.byId(id)))
               } else if let _ = likeData.commentId {
                  if let id = likeData.transactionId {
                     return .presentDetails(.transaction(.transactId(id)))
                  } else if let id = likeData.challengeId {
                     return .presentDetails(.challenge(.byId(id)))
                  }
               }
               //
            case .challengeWin:
               guard let chall = NotificationToChallengeDetailsData.convert($0) else {
                  return .presentNothing
               }

               return .presentDetails(.challenge(.byChallenge(chall)))
               //
            case .newReportToChallenge:
               guard let reportId = $0.reportData?.reportId else {
                  return .presentNothing
               }
              
               return .presentReportData(reportId)
//               let input = ContenderDetailsSceneInput.winnerReportId(reportId, false)
//               Asset.router?.route(
//                  .push,
//                  scene: \.challengeContenderDetail,
//                  payload: input,
//                  finishWork: nil
//               )
//               return
//               return .presentNothing
               //
            case .challengeFinished:
               guard let challengeEndingData = $0.challengeEndingData else {
                  return .presentNothing
               }
               if let id = challengeEndingData.challengeId {
                  return .presentDetails(.challenge(.byId(id)))
               }
            case.marketplace:
               return .presentNothing
            case .questionnaire:
               return .presentNothing
               //
            case .none:
               return .presentNothing
            }

            return .presentNothing
         }
   }
}
