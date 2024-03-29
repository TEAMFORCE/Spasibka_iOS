//
//  ChangeOrgVerifyUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2022.
//

import StackNinja

struct ChangeOrgVerifyCodeUseCase: UseCaseProtocol {
   let changeOrgVerifyApiWorker: ChangeOrgVerifyApiWorker

   var work: Work<VerifyRequest, VerifyResultBody> {
      changeOrgVerifyApiWorker.work
   }
}
