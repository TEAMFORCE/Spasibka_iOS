//
//  SetFlagUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 21.11.2023.
//

import StackNinja

struct SetFlagUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol

   var work: Work<Bool, Void> { .init { work in
      let flag = work.in
      
      apiEngine
         .process(endpoint: SpasibkaEndpoints.SetFlag(body: ["flag": flag]))
         .onSuccess { result in
            guard
               let _ = FlagResponse(result.data)
            else {
               work.fail()
               return
            }
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }
}
