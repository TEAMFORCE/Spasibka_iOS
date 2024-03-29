//
//  BalanceWorks.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 01.09.2022.
//

import Foundation
import StackNinja

final class BalanceWorksStorage: InitProtocol {
   var foundUsers: [FoundUser] = []
   var transactions: [Transaction] = []
}

protocol BalanceWorksProtocol {
   var loadBalance: Out<Balance> { get }
}

final class BalanceWorks<Asset: AssetProtocol>: BaseWorks<BalanceWorksStorage, Asset>, BalanceWorksProtocol {
   private lazy var apiUseCase = Asset.apiUseCase
   private lazy var storageUseCase = Asset.safeStorageUseCase
   private lazy var userDefaults = Asset.userDefaultsWorks

   var loadBalance: Out<Balance> {
      apiUseCase.loadBalance
   }

   var getUserList: Work<Void, [FoundUser]> { .init { [weak self] work in
      self?.apiUseCase.getUsersList
         .doAsync(10)
         .onSuccess { result in
            Self.store.foundUsers = result
            work.success(result: result)
         }.onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var fetchButtonsInfo: Work<Void, [TransactButtonInfo]> { .init { work in
      let result = Self.store.foundUsers.map {
         TransactButtonInfo(username: self.generateUsername(name: $0.name.unwrap,
                                                            surname: $0.surname.unwrap),
                            photo: $0.photo)
      }
      work.success(result)
   }.retainBy(retainer) }

   var getUserId: In<Int>.Out<Int> { .init { work in
      guard let index = work.input else { work.fail(); return }
      if let id = Self.store.foundUsers[safe: index - 1]?.userId {
         work.success(id)
      } else {
         work.fail()
      }
   }.retainBy(retainer) }

   var getUserData: Out<UserData> { .init { [weak self] work in
      guard let self else { work.fail(); return }
      self.userDefaults.loadAssociatedValueWork()
         .doAsync(UserDefaultsValue.currentUser(nil))
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getNotificationsAmount: Work<Void, Int> { .init { [weak self] work in
      self?.apiUseCase.getNotificationsAmount
         .doAsync()
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
   
   private func generateUsername(name: String, surname: String) -> String {
      return (name + " " + surname.prefix(1) + ".")
   }
}

extension BalanceWorks {
   var loadTransactions: VoidWork { .init { [weak self] work in
      let request = HistoryRequest(pagination: Pagination(offset: 1, limit: 4))
      self?.apiUseCase.getTransactions
         .doAsync(request)
         .onSuccess {
            Self.store.transactions = $0
            work.success()
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getAllTransactItems: Work<Void, [TableItemsSection]> {
      .init { [weak self] work in
         self?.storageUseCase.getCurrentProfileId
            .doAsync()
            .doMap {
               let filtered = Self.store.transactions
               let items = HistoryWorks<Asset>.convertToItems(filtered, $0.toInt)
               work.success(result: items)
            }
            .onFail {
               work.fail()
            }
      }
      .retainBy(retainer)
   }

   var getTransactionByRowNumber: In<(IndexPath, Int)>.Out<Transaction> {
      .init { work in
         guard let index = work.input?.1 else { work.fail(); return }

         if let transaction = Self.store.transactions[safe: index] {
            work.success(result: transaction)
         } else {
            work.fail()
         }
      }.retainBy(retainer)
   }
}

struct TransactButtonInfo {
   let username: String
   let photo: String?
}
