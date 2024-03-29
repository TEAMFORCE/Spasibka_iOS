//
//  StringStorageUseCase.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 25.08.2022.
//

import StackNinja

struct StringStorageUseCase: UseCaseProtocol {
   let storageEngine: StringStorageProtocol

   var work: Work<String, String> { .init { work in
      guard
         let input = work.input,
         let value = storageEngine.load(forKey: input)
      else {
         print("\nNo value for key: \(String(describing: work.input))\n")

         work.fail()

         return
      }

      work.success(result: value)
   }}
}
