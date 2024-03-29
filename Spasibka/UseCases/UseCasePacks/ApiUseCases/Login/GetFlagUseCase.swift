//
//  GetFlagUseCase.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 21.11.2023.
//

import StackNinja

struct FlagResponse: Codable {
   let flag: Bool?
}

struct GetFlagUseCase: UseCaseProtocol {
   let apiEngine: ApiWorksProtocol

   var work: Work<Void, Bool> { .init { work in

      apiEngine
         .process(endpoint: SpasibkaEndpoints.GetFlag(headers: [:]))
         .onSuccess { result in
            guard
               let response = FlagResponse(result.data)
            else {
               work.fail()
               return
            }
            work.success(result: response.flag ?? false)
         }
         .onFail {
            work.fail()
         }
   } }
}
