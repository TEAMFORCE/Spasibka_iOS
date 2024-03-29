//
//  UseCaseRegistry.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.08.2022.
//

import StackNinja

struct UserSearchUseCase: UseCaseProtocol {
   let searchUserApiModel: SearchUserApiWorker

   var work: Work<SearchUserRequest, [FoundUser]> {
      searchUserApiModel.work
   }
}
