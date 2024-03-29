//
//  StatusSelectorWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja

final class StatusSelectorStorage: InitProtocol {
   init() {}

   var mode: StatusSelectorInput = .mainStatus
   var statusList: [UserStatus] = []
}

final class StatusSelectorWorks<Asset: ASP>: BaseWorks<StatusSelectorStorage, Asset> {}

extension StatusSelectorWorks: UserStatusWorksProtocol {}

protocol UserStatusWorksProtocol: WorksProtocol, StorageProtocol where
   Store: StatusSelectorStorage
{
   var loadUserStatusList: Work<Void, Void> { get }
   //
   var getUserStatusList: Work<Void, [UserStatus]> { get }
   var getUserStatusByIndex: Work<Int, UserStatus> { get }
}

extension UserStatusWorksProtocol {
   var saveInput: Work<StatusSelectorInput, Void> { .init { work in
      guard let mode = work.input else { work.fail(); return }
      Self.store.mode = mode
      work.success()
   }.retainBy(retainer) }
   
   var loadUserStatusList: Work<Void, Void> {.init { work in
      //TODO: - Fish
      if Self.store.mode == .mainStatus {
         Self.store.statusList = [UserStatus.office, UserStatus.remote]
      } else {
         Self.store.statusList = [UserStatus.vacation, UserStatus.sickLeave, UserStatus.working]
      }
      work.success()
   }.retainBy(retainer) }
   //
   var getUserStatusList: Work<Void, [UserStatus]> { .init { work in
      work.success(Self.store.statusList)
   }.retainBy(retainer) }

   var getUserStatusByIndex: Work<Int, UserStatus> { .init { work in
      guard let index = work.input else { work.fail(); return }
      if Self.store.statusList.indices.contains(index) {
         work.success(Self.store.statusList[index])
      } else {
         work.fail()
      }
   }.retainBy(retainer) }
}


