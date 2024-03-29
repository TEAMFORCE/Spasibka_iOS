//
//  HistoryWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 16.08.2022.
//

import Foundation
import StackNinja

protocol HistoryWorksProtocol: Assetable {}

final class HistoryWorks<Asset: AssetProtocol>: BaseWorks<HistoryWorks.Temp, Asset>, HistoryWorksProtocol {
   private lazy var useCase = Asset.apiUseCase
   let storageUseCase = Asset.safeStorageUseCase

   // Temp Storage
   final class Temp: InitProtocol {
      var userData: UserData?
      //
      var transactions: [Transaction] = [] {
         didSet {
            print("")
         }
      }
      var sections: [TableItemsSection]?
      var currentTransaction: Transaction?
      var segmentId: Int = 0

      var sentTransactions: [Transaction] = [] {
         didSet {
            print("")
         }
      }
      var recievedTransactions: [Transaction] = [] {
         didSet {
            print("")
         }
      }
      
      var groupTransactions: [TransactionByGroup] = []

      let allTransactPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
      let sentTransactPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
      let recievedTransactPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
      let groupTransactPaginator = PaginationSystem(pageSize: 20, startOffset: 1)
      
      var isGroupSelected: Bool?
   }

   // MARK: - Init Work
   
   var initStorageAndLoadAllTransactionsFromServer: Work<UserData, Void> {
      .init { [weak self] work in
         if Self.store.userData == nil {
            Self.store.userData = work.unsafeInput
         }
         
         Self.store.allTransactPaginator.reInit()
         Self.store.sentTransactPaginator.reInit()            
         Self.store.recievedTransactPaginator.reInit()
         Self.store.groupTransactPaginator.reInit()
         
         Self.store.transactions = []
         Self.store.sentTransactions = []
         Self.store.recievedTransactions = []
         Self.store.groupTransactions = []
         
         self?.loadAllTransactionsFromServer
            .doAsync()
            .onSuccess { work.success() }
            .onFail { work.fail() }
         self?.loadSentTransactionsFromServer
            .doAsync()
            .onFail { work.fail() }
         self?.loadRecievedTransactionsFromServer
            .doAsync()
            .onFail { work.fail() }
         self?.loadGroupTransactionsFromServer
            .doAsync()
            .onFail{ work.fail() }
      }
   }
   
   var getUserData: Out<UserData> { .init { work in
      guard let userDate = Self.store.userData else { work.fail(); return }
      work.success(userDate)
   }.retainBy(retainer) }
   
   // MARK: - Works

   var requestPagination: Out<(Bool, [TableItemsSection])> { .init { [weak self] work in
      if let isGroupSelected = Self.store.isGroupSelected, isGroupSelected == true {
         self?.loadGroupTransactionsFromServer
            .doAsync()
            .onSuccess {
               self?.getGroupTransactItems
                  .doAsync(true)
                  .onSuccess { result in
                     work.success((true, result.1))
                  }
                  .onFail {
                     work.fail()
                  }
            }
            .onFail {
               work.fail()
            }
         return
      }
      
      switch Self.store.segmentId {
      case 0:
         self?.loadAllTransactionsFromServer
            .doAsync()
            .onSuccess {
               self?.getAllTransactItems
                  .doAsync()
                  .onSuccess {
                     work.success((false,$0))
                  }
                  .onFail {
                     work.fail()
                  }
            }
            .onFail { work.fail() }
      case 1:
         self?.loadRecievedTransactionsFromServer
            .doAsync()
            .onSuccess {
               self?.getRecievedTransactItems
                  .doAsync()
                  .onSuccess {
                     work.success((false,$0))
                  }
                  .onFail {
                     work.fail()
                  }
            }
            .onFail { work.fail() }
      case 2:
         self?.loadSentTransactionsFromServer
            .doAsync()
            .onSuccess {
               self?.getSentTransactItems
                  .doAsync()
                  .onSuccess {
                     work.success((false, $0))
                  }
                  .onFail {
                     work.fail()
                  }
            }
            .onFail { work.fail() }
      default:
         work.fail()
      }
   }.retainBy(retainer) }

   var filterWork: Work<Button3Event, [TableItemsSection]> { .init { [weak self] work in
      guard let self, let button = work.input else { work.fail(); return }

      switch button {
      case .didTapButton1:
         self.getAllTransactItems
            .doAsync()
            .onSuccess { work.success($0) }
            .onFail { work.fail() }

      case .didTapButton2:
         self.getRecievedTransactItems
            .doAsync()
            .onSuccess { work.success($0) }
            .onFail { work.fail() }

      case .didTapButton3:
         self.getSentTransactItems
            .doAsync()
            .onSuccess { work.success($0) }
            .onFail { work.fail() }
      }
   }.retainBy(retainer) }

   var getTransactionById: Work<Int, Transaction> {
      .init { [weak self] work in
         self?.useCase.getTransactionById
            .doAsync()
            .onSuccess {
               Self.store.currentTransaction = $0
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
      .retainBy(retainer)
   }

   //
   var getProfileById: Work<Int, UserData> {
      .init { [weak self] work in
         self?.useCase.getProfileById
            .doAsync(work.input)
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               work.fail()
            }
      }
      .retainBy(retainer)
   }

   var getTransactionByRowNumber: Work<(IndexPath, Int), Transaction> {
      .init { work in
         if let isGroupSelected = Self.store.isGroupSelected, isGroupSelected == true {
            work.fail()
            return
         }
         let segmentId = Self.store.segmentId
         var filtered: [Transaction] = []
         if segmentId == 0 { filtered = Self.store.transactions }
         else if segmentId == 1 { filtered = Self.store.recievedTransactions }
         else if segmentId == 2 { filtered = Self.store.sentTransactions }

         if let index = work.input?.1 {
            let transaction = filtered[index]
            work.success(result: transaction)
         } else {
            work.fail()
         }
      }
      .retainBy(retainer)
   }

   var getAllTransactItems: Work<Void, [TableItemsSection]> {
      .init {
         let filtered = Self.store.transactions
         let items = Self.convertToItems(filtered)
         Self.store.segmentId = 0

         $0.success(result: items)
      }
      .retainBy(retainer)
   }

   var getSentTransactItems: Work<Void, [TableItemsSection]> {
      .init {
         let filtered = Self.store.sentTransactions
         let items = Self.convertToItems(filtered)
         Self.store.segmentId = 2

         $0.success(result: items)
      }
      .retainBy(retainer)
   }

   var getRecievedTransactItems: Work<Void, [TableItemsSection]> {
      .init {
         let filtered = Self.store.recievedTransactions
         let items = Self.convertToItems(filtered)
         Self.store.segmentId = 1

         $0.success(result: items)
      }
      .retainBy(retainer)
   }
   
   var getGroupTransactItems: In<Bool>.Out<(Bool, [TableItemsSection])> {
      .init { work in
         guard let input = work.input else { work.fail(); return }
         Self.store.isGroupSelected = input
         let filtered = Self.store.groupTransactions
         let items = Self.convertToItemsGroup(filtered)
         work.success(result: (input, items))
      }
      .retainBy(retainer)
   }
   

   var cancelTransactionById: Work<Int, Void> {
      .init { [weak self] work in
         self?.useCase.cancelTransactionById
            .doAsync(work.input)
            .onSuccess {
               print("cancelled transaction successfully")
               work.success()
            }
            .onFail {
               work.fail()
            }

      }.retainBy(retainer)
   }

   var getSegmentId: Work<Void, Int> { .init { work in
      work.success(Self.store.segmentId)
   }.retainBy(retainer) }

   var getTransactionsBySegment: Work<Int, [TableItemsSection]> { .init { [weak self] work in
      guard let id = work.input else { work.fail(); return }
      switch id {
      case 0:
         self?.getAllTransactItems
            .doAsync()
            .onSuccess { work.success($0) }
            .onFail { work.fail() }
      case 1:
         self?.getRecievedTransactItems
            .doAsync()
            .onSuccess { work.success($0) }
            .onFail { work.fail() }
      case 2:
         self?.getSentTransactItems
            .doAsync()
            .onSuccess { work.success($0) }
            .onFail { work.fail() }

      default:
         work.fail()
      }
   }.retainBy(retainer) }
}

// MARK: - Load from server

private extension HistoryWorks {
   var loadAllTransactionsFromServer: VoidWork { .init { [weak self] work in
      guard Self.store.allTransactPaginator.isReady else { work.fail(); return }

      let currentPage = Self.store.allTransactPaginator.getCurrentPage()
      let request = HistoryRequest(pagination: currentPage)
      
      self?.useCase.getTransactions
         .doAsync(request)
         .onSuccess {
            if $0.isEmpty {
               Self.store.allTransactPaginator.finished()
            } else {
               Self.store.allTransactPaginator.pageLoaded()
               Self.store.transactions.append(contentsOf: $0)
            }
            work.success()
         }
         .onFail {
            Self.store.allTransactPaginator.pageLoadError()
            work.fail()
         }
   }.retainBy(retainer) }

   var loadRecievedTransactionsFromServer: VoidWork { .init { [weak self] work in
      guard Self.store.recievedTransactPaginator.isReady else { work.fail(); return }
      
      let pagination = Self.store.recievedTransactPaginator.getCurrentPage()
      let request = HistoryRequest(
         pagination: pagination,
         receivedOnly: true
      )

      self?.useCase.getTransactions
         .doAsync(request)
         .onSuccess {
            if $0.isEmpty {
               Self.store.recievedTransactPaginator.finished()
            } else {
               Self.store.recievedTransactPaginator.pageLoaded()
               Self.store.recievedTransactions.append(contentsOf: $0)
            }
            work.success()
         }
         .onFail {
            Self.store.recievedTransactPaginator.pageLoadError()
            work.fail()
         }
   }.retainBy(retainer) }

   var loadSentTransactionsFromServer: VoidWork { .init { [weak self] work in
      guard Self.store.sentTransactPaginator.isReady else { work.fail(); return }
      
      let pagination = Self.store.sentTransactPaginator.getCurrentPage()
      let request = HistoryRequest(
         pagination: pagination,
         sentOnly: true
      )
      
      self?.useCase.getTransactions
         .doAsync(request)
         .onSuccess {
            if $0.isEmpty {
               Self.store.sentTransactPaginator.finished()
            } else {
               Self.store.sentTransactPaginator.pageLoaded()
            }
            Self.store.sentTransactions.append(contentsOf: $0)
            work.success()
         }
         .onFail {
            Self.store.recievedTransactPaginator.pageLoadError()
            work.fail()
         }
   }.retainBy(retainer) }
   
   var loadGroupTransactionsFromServer: VoidWork { .init { [weak self] work in
      guard Self.store.groupTransactPaginator.isReady else { work.fail(); return }

      let currentPage = Self.store.groupTransactPaginator.getCurrentPage()
      
      self?.useCase.getTransactionsByGroup
         .doAsync(currentPage)
         .onSuccess {
            if $0.isEmpty {
               Self.store.groupTransactPaginator.finished()
            } else {
               Self.store.groupTransactPaginator.pageLoaded()
            }
            Self.store.groupTransactions.append(contentsOf: $0)
            work.success()
         }
         .onFail {
            Self.store.recievedTransactPaginator.pageLoadError()
            work.fail()
         }
   }.retainBy(retainer) }
}

extension HistoryWorks {
   private static func convertToItemsGroup(_ filtered: [TransactionByGroup]) -> [TableItemsSection] {
      guard !filtered.isEmpty else { return [] }
      
      var prevDay = ""
      
      return filtered
         .reduce([TableItemsSection]()) { result, transact in
            var result = result

            var currentDay = transact.date?.dateConvertedDDMMYY
            if let date = transact.date?.dateConvertedToDate {
               if Calendar.current.isDateInToday(date) {
                  currentDay = Design.text.today
               } else if Calendar.current.isDateInYesterday(date) {
                  currentDay = Design.text.yesterday
               }
            }

            if prevDay != currentDay {
               result.append(TableItemsSection(title: currentDay.string))
            }

            result.last?.items.append(transact)
            prevDay = currentDay.string
            return result
         }
   }
   public static func convertToItems(_ filtered: [Transaction], _ profileId: Int? = nil) -> [TableItemsSection] {
      guard !filtered.isEmpty else { return [] }

      var prevDay = ""

      return filtered
         .reduce([TableItemsSection]()) { result, transact in
            var state = TransactionItem.State.waiting
            let transactionStatus = transact.transactionStatus?.id
            switch transactionStatus {
            case "W":
               state = TransactionItem.State.waiting
            case "A":
               state = TransactionItem.State.approved
            case "D":
               state = TransactionItem.State.declined
            case "I":
               state = TransactionItem.State.ingrace
            case "R":
               state = TransactionItem.State.ready
            case "C":
               state = TransactionItem.State.cancelled
            default:
               state = TransactionItem.State.waiting
            }

            var authorPhoto = transact.recipient?.recipientPhoto

            //let isSentTransact = (transact.senderId == Self.store.userData?.profile.id)
            let userDataId = profileId == nil ? Self.store.userData?.id : profileId
            let isSentTransact = (transact.senderId == userDataId)

            if isSentTransact == false {
               state = .recieved
               authorPhoto = transact.sender?.senderPhoto
            }

            let item = TransactionItem(
               state: state,
               sender: transact.sender ?? Sender(senderId: nil,
                                                 senderTgName: nil,
                                                 senderFirstName: nil,
                                                 senderSurname: nil,
                                                 senderPhoto: nil,
                                                 challengeName: nil,
                                                 challengeId: nil),
               recipient: transact.recipient ?? Recipient(recipientId: nil,
                                                          recipientTgName: nil,
                                                          recipientFirstName: nil,
                                                          recipientSurname: nil,
                                                          recipientPhoto: nil),
               amount: transact.amount.unwrap,
               createdAt: transact.createdAt.unwrap,
               photo: authorPhoto,
               isAnonymous: transact.isAnonymous ?? false,
               id: transact.id,
               transactClass: transact.transactionClass,
               canUserCancel: transact.canUserCancel,
               isSentTransact: isSentTransact
            )

            var result = result

            var currentDay = item.createdAt.dateConvertedDDMMYY
            if let date = item.createdAt.dateConvertedToDate {
               if Calendar.current.isDateInToday(date) {
                  currentDay = Design.text.today
               } else if Calendar.current.isDateInYesterday(date) {
                  currentDay = Design.text.yesterday
               }
            }

            if prevDay != currentDay {
               result.append(TableItemsSection(title: currentDay))
            }

            result.last?.items.append(item)
            prevDay = currentDay
            return result
         }
   }
}
