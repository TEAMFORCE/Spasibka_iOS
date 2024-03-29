//
//  BalanceScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 01.09.2022.
//

import Foundation
import StackNinja

struct BalanceScenarioInputEvents: ScenarioEvents {
   let didTapNewTransactSegment: Out<Int>
   let didSelectHistoryItem: Out<(IndexPath, Int)>
   let presentHistoryScene: Out<Void>
   let reloadNewNotifies: VoidWork
}

final class BalanceScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<BalanceScenarioInputEvents, BalanceSceneState, BalanceWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()
      
      start
         .doNext(works.loadBalance)
         .onSuccess(setState) { .balanceDidLoad($0) }
         .onFail(setState, .loadBalanceError)
         .doVoidNext(works.getUserList)
         .doVoidNext(works.fetchButtonsInfo)
         .onSuccess(setState) { .setTransactInfo($0) }
         .doVoidNext(works.loadTransactions)
         .doVoidNext(works.getAllTransactItems)
         .onSuccess(setState) { .presentTransactions($0) }
         .doVoidNext(works.getUserData)
         .onSuccess(setState) { .setUserProfileInfo($0.profile.firstName.unwrap, $0.profile.photo) }
      
      events.didTapNewTransactSegment
         .doNext(works.getUserId)
         .onSuccess(setState) { .presentTransactScene($0) }
         .onFail(setState) { .presentTransactScene(nil) }
      
      events.didSelectHistoryItem
         .doNext(works.getTransactionByRowNumber)
         .onSuccess(setState) { .presentHistoryDetailView($0)}
      
      events.presentHistoryScene
         .doNext(works.getUserData)
         .onSuccess(setState) { .presentHistoryScene($0) }
      
      events.reloadNewNotifies
         .doVoidNext(works.getNotificationsAmount)
         .onSuccess(setState) { .updateAlarmButtonWithNewNotificationsCount($0) }
   }
}
