//
//  GetCurrentUserUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.11.2022.
//

import StackNinja

fileprivate let currentUserKey = "currentUser"
fileprivate let currentUserIdKey = "currentUserId"
fileprivate let currentProfileIdKey = "currentProfileId"
fileprivate let currentUserRole = "currentUserRole"

struct GetCurrentUserUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageProtocol

   var work: Out<String> {
      .init {
         guard let curUser = safeStringStorage.load(forKey: currentUserKey) else {
            $0.fail()
            return
         }

         $0.success(curUser)
      }
   }
}

struct SaveCurrentUserUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageProtocol

   var work: Work<String, String> {
      .init {
         safeStringStorage.save($0.unsafeInput, forKey: currentUserKey)

         $0.success($0.unsafeInput)
      }
   }
}

struct GetCurrentUserIdUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageProtocol

   var work: Out<String> {
      .init {
         guard let curUser = safeStringStorage.load(forKey: currentUserIdKey) else {
            $0.fail()
            return
         }

         $0.success(curUser)
      }
   }
}

struct SaveCurrentUserIdUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageProtocol

   var work: Work<String, String> {
      .init {
         safeStringStorage.save($0.unsafeInput, forKey: currentUserIdKey)

         $0.success($0.unsafeInput)
      }
   }
}

struct GetCurrentProfileIdUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageProtocol

   var work: Out<String> {
      .init {
         guard let res = safeStringStorage.load(forKey: currentProfileIdKey) else {
            $0.fail()
            return
         }

         $0.success(res)
      }
   }
}

struct GetCurrentUserRoleUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageProtocol
   
   var work: Out<String> {
      .init {
         guard let res = safeStringStorage.load(forKey: currentUserRole) else {
            $0.fail()
            return
         }
         
         $0.success(res)
      }
   }
}

struct SaveCurrentUserRoleUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageProtocol
   
   var work: Work<String, String> {
      .init {
         safeStringStorage.save($0.unsafeInput, forKey: currentUserRole)
         
         $0.success($0.unsafeInput)
      }
   }
}

struct SaveCurrentProfileIdUseCase: UseCaseProtocol {
   let safeStringStorage: StringStorageProtocol

   var work: Work<String, String> {
      .init {
         safeStringStorage.save($0.unsafeInput, forKey: currentProfileIdKey)

         $0.success($0.unsafeInput)
      }
   }
}

