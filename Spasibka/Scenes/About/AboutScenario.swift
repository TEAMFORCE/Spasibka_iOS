//
//  AboutScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.12.2022.
//

import StackNinja

struct AboutScenarioEvents: ScenarioEvents {}

struct AboutScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = AboutScenarioEvents
   typealias ScenarioModelState = AboutSceneState
   typealias ScenarioWorks = AboutWorks<Asset>
}

final class AboutScenario<Asset: ASP>: BaseParamsScenario<AboutScenarioParams<Asset>> {
   override func configure() {
      super.configure()
      
      start
         .doNext(works.getLicenseEnd)
         .onSuccess(setState) { .licenseEndData($0) }
         .doAnyway(works.startUpdatingLocation, on: .globalBackground)
         .doAsync()
         .doInput([.country])
         .doNext(works.getUserLocationData)
         .onSuccess(setState) { .locationData($0) }
         .onFail(setState) { .locationData(.init(locationName: "Не определен", geoPosition: .init())) }
   }
}
