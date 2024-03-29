//
//  SentTransactWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.02.2023.
//

import StackNinja

final class SentTransactDetailsStorage: InitClassProtocol {}

final class SentTransactDetailsWorks<Asset: ASP>: BaseWorks<SentTransactDetailsStorage, Asset> {
   lazy var storageUseCase = Asset.safeStorageUseCase
   private lazy var apiUseCase = Asset.apiUseCase
   
   var loadTransaction: In<Transaction>.Out<Transaction> { .init { [weak self] work in
      guard let id = work.input?.id else { work.fail(); return }
     
      self?.apiUseCase.getTransactionById
         .doAsync(id)
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var checkIsMyTransaction: In<Transaction>.Out<(transaction: Transaction, isMy: Bool)> { .init { [weak self] work in
      
      self?.storageUseCase.getCurrentProfileId
         .doAsync()
         .onSuccess {
            if String(work.in.senderId.unwrap) == $0 {
               work.success((transaction: work.in, isMy: true))
            } else {
               work.success((transaction: work.in, isMy: false))
            }
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }
}
