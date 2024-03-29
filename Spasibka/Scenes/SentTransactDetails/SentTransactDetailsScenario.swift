//
//  SentTransactDetailsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.02.2023.
//

import StackNinja

struct SentTransactDetailsEvents: ScenarioEvents {
   let inputTransaction: Out<Transaction>
}

struct SentTransactDetailsScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = SentTransactDetailsEvents

   typealias ScenarioModelState = SentTransactDetailsState

   typealias ScenarioWorks = SentTransactDetailsWorks<Asset>
}

final class SentTransactDetailsScenario<Asset: ASP>: BaseParamsScenario<SentTransactDetailsScenarioParams<Asset>> {
   override func configure() {
      super.configure()
      
      events.inputTransaction
         .doNext(works.loadTransaction)
         .doNext(works.checkIsMyTransaction)
         .onSuccess(setState) { .initial(transaction: $0.transaction, isMy: $0.isMy) }
   }
}


