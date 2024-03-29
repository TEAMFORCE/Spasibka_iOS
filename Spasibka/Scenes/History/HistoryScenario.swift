//
//  HistoryScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 16.08.2022.
//

import StackNinja
import UIKit

struct HistoryScenarioEvents: ScenarioEvents {   
   let initial: VoidWork
   
   let loadHistoryForCurrentUser: Out<UserData>

   let filterTapped: Out<Button3Event>

   let presentDetailView: Out<(IndexPath, Int)>
   let showCancelAlert: Out<Int>
   let cancelTransact: Out<Int>
   
   let requestPagination: VoidWork
   let groupFilterTapped: Out<Bool>
}

final class HistoryScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<HistoryScenarioEvents, HistoryState, HistoryWorks<Asset>>
{
   override func configure() {
      super.configure()
      
      events.loadHistoryForCurrentUser
         .doNext(works.initStorageAndLoadAllTransactionsFromServer)
         .doNext(works.getSegmentId)
         .doNext(works.getTransactionsBySegment)
         .onSuccess(setState) {
            .presentTransactions($0)
         }

      events.filterTapped
         .onSuccess(setState) { _ in .clearTableModel }
         .doNext(works.filterWork)
         .onSuccess(setState) {
            .presentTransactions($0)
         }
         .onFail(setState) {
            .loadTransactionsError
         }
      
      events.presentDetailView
         .doNext(works.getTransactionByRowNumber)
         .onSuccess(setState) { .presentDetailView($0)}
      
      events.showCancelAlert
         .onSuccess(setState) { .cancelAlert($0) }
      
      events.cancelTransact
         .doNext(works.cancelTransactionById)
         .onSuccess(setState) { .cancelTransaction }
//         .onFail {
//            print("can not cancel transaction")
//         }
         .doNext(works.getUserData)
         .onSuccess {
            self.events.loadHistoryForCurrentUser.sendAsyncEvent($0)
         }
      
      events.requestPagination
         .doNext(works.requestPagination)
         .onSuccess(setState) {
            if $0.0 == true {
               return .presentGroupTransactions($0.1)
            } else {
               return .presentTransactions($0.1)
            }
         }
      
      events.groupFilterTapped
         .onSuccess(setState) { _ in .clearTableModel }
         .doNext(works.getGroupTransactItems)
         .onSuccess(setState) {
            if $0.0 == true {
               return .presentGroupTransactions($0.1)
            } else {
               return .setNormalMode
            }
         }
   }
}
