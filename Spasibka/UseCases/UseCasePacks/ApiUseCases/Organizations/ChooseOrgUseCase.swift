//
//  ChooseOrgUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import StackNinja

struct ChooseOrgUseCase: UseCaseProtocol {
   let chooseOrgApiWorker: ChooseOrgApiWorker

   var work: Work<OrganizationAuth, AuthResult> {
      chooseOrgApiWorker.work
   }
}
