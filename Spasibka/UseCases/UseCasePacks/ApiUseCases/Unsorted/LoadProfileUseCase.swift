//
//  LoadProfileUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.08.2022.
//

import Foundation
import StackNinja

struct LoadProfileUseCase: UseCaseProtocol {
   let loadToken: LoadTokenWorker
   let saveUserNameWork: SaveCurrentUserUseCase
   let saveUserIdWork: SaveCurrentUserIdUseCase
   let saveProfileIdWork: SaveCurrentProfileIdUseCase
   let userProfileApiModel: GetMyProfileApiWorker
   let saveUserRole: SaveCurrentUserRoleUseCase

   var work: Work<Void, UserData> {
      Work<Void, UserData> { work in
         loadToken
            .doAsync()
            .onFail {
               work.fail()
            }.doMap {
               TokenRequest(token: $0)
            }
            .doNext(userProfileApiModel)
            .onFail {
               work.fail()
            }
            .doSaveResult()
            .doMap {
               $0.userName
            }
            .doNext(saveUserNameWork)
            .onFail {
               assertionFailure("cannot save saveUserNameWork")
            }
            .doLoadResult()
            .doMap { (userData: UserData) in
               userData.profile.id.toString
            }
            .doNext(saveUserIdWork)
            .doLoadResult()
            .doMap { (userData: UserData) in
               if let id = userData.id {
                  return id.toString
               } else {
                  return "profile id not found"
               }
            }
            .doNext(saveProfileIdWork)
            .onFail {
               print("cannot save profileId")
            }
            .doLoadResult()
            .onSuccess {
               work.success(result: $0)
            }
            .onFail {
               assertionFailure("cannot save saveUserNameWork")
            }
            .doLoadResult()
            .doMap { (userDate: UserData) in
               if userDate.privileged.indices.contains(0) {
                  return userDate.privileged[0].role
               }
               return ""
            }
            .doNext(saveUserRole)
            .onFail {
               print("cannot save userRole")
            }
            .onSuccess {
               work.success(result: $0)
            }
            
      }
   }
}
