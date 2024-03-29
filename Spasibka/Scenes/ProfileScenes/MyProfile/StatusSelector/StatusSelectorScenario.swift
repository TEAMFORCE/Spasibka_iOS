//
//  StatusSelectorScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja

struct StatusSelectorInputEvents: ScenarioEvents {
   let saveInput: Out<StatusSelectorInput>
   let didSelectStatus: Work<Void, Int>
}

struct StatusSelectorScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = StatusSelectorInputEvents
   typealias ScenarioModelState = StatusSelectorState
   typealias ScenarioWorks = StatusSelectorWorks<Asset>
}

final class StatusSelectorScenario<Asset: ASP>: BaseParamsScenario<StatusSelectorScenarioParams<Asset>> {
   override func configure() {
      super.configure()

//      start
//         .doNext(works.loadUserStatusList)
//         .doNext(works.getUserStatusList)
//         .onSuccess(setState) { .presentStatusList($0) }

      events.saveInput
         .onSuccess(setState) { .setTitle($0)}
         .doNext(works.saveInput)
         .doNext(works.loadUserStatusList)
         .doNext(works.getUserStatusList)
         .onSuccess(setState) { .presentStatusList($0) }

      events.didSelectStatus
         .doNext(works.getUserStatusByIndex)
         .onSuccess(setState) { .selectStatusAndDismiss($0) }
   }
}
