//
//  HistoryWorks.swift
//  TeamForce
//
//  Created by Yerzhan Gapurinov on 16.08.2022.
//

import Foundation
import ReactiveWorks

protocol HistoryWorksProtocol {
   var loadProfile: Work<Void, Void> { get }
   var getTransactions: Work<Void, [Transaction]> { get }
   var getTransactionById: Work<Int, Transaction> { get }

   var getAllTransactItems: Work<Void, [TableItemsSection]> { get }
   var getSentTransactItems: Work<Void, [TableItemsSection]> { get }
   var getRecievedTransactItems: Work<Void, [TableItemsSection]> { get }
}

final class HistoryWorks<Asset: AssetProtocol>: BaseSceneWorks<HistoryWorks.Temp, Asset>, HistoryWorksProtocol {
   private lazy var useCase = Asset.apiUseCase

   // Temp Storage
   final class Temp: InitProtocol {
      var currentUser: String?
      var transactions: [Transaction]?
      var sections: [TableItemsSection]?
      var currentTransaction: Transaction?
      var segmentId: Int?
   }

   // MARK: - Works

   lazy var getTransactions = Work<Void, [Transaction]>() { [weak self] work in
      self?.useCase.getTransactions.work
         .retainBy(self?.retainer)
         .doAsync()
         .onSuccess {
            Self.store.transactions = $0
            work.success(result: $0)
         }
         .onFail {
            work.fail(())
         }
   }

   lazy var getTransactionById = Work<Int, Transaction>() { [weak self] work in
      self?.useCase.getTransactionById.work
         .retainBy(self?.retainer)
         .doAsync()
         .onSuccess {
            Self.store.currentTransaction = $0
            work.success(result: $0)
         }
         .onFail {
            work.fail(())
         }
   }
   
   lazy var getTransactionByRowNumber = Work<(IndexPath, Int), Transaction>() { [weak self] work in
      
      let segmentId = Self.store.segmentId
      var filtered: [Transaction] = []
      if segmentId == 0 { filtered = Self.filteredAll() }
      else if segmentId == 1 { filtered = Self.filteredRecieved() }
      else if segmentId == 2 { filtered = Self.filteredSent() }
      
      if let index = work.input?.1 {
         let transaction = filtered[index]
         work.success(result: transaction)
      } else {
         work.fail(())
      }
   }

   lazy var loadProfile = Work<Void, Void>() { [weak self] work in
      self?.useCase.loadProfile.work
         .retainBy(self?.retainer)
         .doAsync()
         .onSuccess {
            Self.store.currentUser = $0.profile.tgName
            work.success(result: ())
         }
         .onFail {
            work.fail(())
         }
   }

   var getAllTransactItems: Work<Void, [TableItemsSection]> {
      .init {
         let filtered = Self.filteredAll()
         let items = Self.convertToItems(filtered)
         Self.store.segmentId = 0
         
         $0.success(result: items)
      }
   }

   var getSentTransactItems: Work<Void, [TableItemsSection]> {
      .init {
         let filtered = Self.filteredSent()
         let items = Self.convertToItems(filtered)
         Self.store.segmentId = 2

         $0.success(result: items)
      }
   }

   var getRecievedTransactItems: Work<Void, [TableItemsSection]> {
      .init {
         let filtered = Self.filteredRecieved()
         let items = Self.convertToItems(filtered)
         Self.store.segmentId = 1
         
         $0.success(result: items)
      }
   }
}

private extension HistoryWorks {
   static func filteredAll() -> [Transaction] {
      guard let transactions = store.transactions else {
         return []
      }

      return transactions
   }

   static func filteredSent() -> [Transaction] {
      guard let transactions = store.transactions else {
         return []
      }

      return transactions.filter {
         $0.sender?.senderTgName == Self.store.currentUser
      }
   }

   static func filteredRecieved() -> [Transaction] {
      guard let transactions = store.transactions else {
         return []
      }

      return transactions.filter {
         $0.sender?.senderTgName != Self.store.currentUser
      }
   }

   static func convertToItems(_ filtered: [Transaction]) -> [TableItemsSection] {
      var prevDay = ""
      print("Filtered \(filtered[0])")
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
            if transact.sender?.senderTgName != Self.store.currentUser {
               state = .recieved
            }
            print(transactionStatus)
            print(state)

            let item = TransactionItem(
               state: state,
               sender: transact.sender ?? Sender(senderId: nil,
                                                 senderTgName: nil,
                                                 senderFirstName: nil,
                                                 senderSurname: nil,
                                                 senderPhoto: nil),
               recipient: transact.recipient ?? Recipient(recipientId: nil,
                                                          recipientTgName: nil,
                                                          recipientFirstName: nil,
                                                          recipientSurname: nil,
                                                          recipientPhoto: nil),
               amount: transact.amount ?? "",
               createdAt: transact.createdAt ?? ""
            )

            var result = result
            let currentDay = item.createdAt.dateConverted

            if prevDay != currentDay {
               result.append(TableItemsSection(title: currentDay))
            }

            result.last?.items.append(item)
            prevDay = currentDay
            return result
         }
   }
}

extension String {
   var dateConverted: String {
      let inputFormatter = DateFormatter()
      inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
      guard let convertedDate = inputFormatter.date(from: self) else { return "" }

      let outputFormatter = DateFormatter()
      outputFormatter.dateFormat = "d MMM y"

      return outputFormatter.string(from: convertedDate)
   }
}
