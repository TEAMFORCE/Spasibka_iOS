//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 15.11.2022.
//

import StackNinja

enum FeedDetailsRouterState {
   case presentDetails(Details, navType: NavType = .push)
   case presentSentTransactDetails(Transaction, navType: NavType = .push)
   case presentNothing
   case presentReportData(Int)

   enum Details {
      case transaction(TransactDetailsSceneInput)
      case challenge(ChallengeDetailsInput)
   }
}

final class FeedDetailsRouter<Asset: AssetProtocol>: Assetable {}

extension FeedDetailsRouter: StateMachine {
   func setState(_ state: FeedDetailsRouterState) {
      switch state {
      case .presentDetails(let details, let navType):
         switch details {
         case .transaction(let input):
            Asset.router?.route(
               navType,
               scene: \.transactDetails,
               payload: input
            )
         case .challenge(let challInput):
            Asset.router?.route(
               navType,
               scene: \.challengeDetails,
               payload: challInput
            )
         }
      //
      case .presentNothing:
         assertionFailure("cannot present details")
      case .presentSentTransactDetails(let transaction, let navType):
         Asset.router?.route(
            navType,
            scene: \.sentTransactDetails,
            payload: transaction
         )
      case .presentReportData(let id):
         let input = ContenderDetailsSceneInput.winnerReportId(id, false)
         Asset.router?.route(
            .push,
            scene: \.challengeContenderDetail,
            payload: input,
            finishWork: nil
         )
      }
   }
}
