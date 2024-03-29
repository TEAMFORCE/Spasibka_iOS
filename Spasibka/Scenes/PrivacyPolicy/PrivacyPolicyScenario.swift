//
//  PrivacyPolicyScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.12.2022.
//

import StackNinja

struct PrivacyPolicyScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = PrivacyPolicyInputEvents
   typealias ScenarioModelState = PrivacyPolicySceneState
   typealias ScenarioWorks = PrivacyPolicyWorks<Asset>
}

struct PrivacyPolicyInputEvents: ScenarioEvents {   
   let input: Out<(title: String, pdfName: String)>
}

class PrivacyPolicyScenario<Asset: ASP>: BaseParamsScenario<PrivacyPolicyScenarioParams<Asset>> {
   override func configure() {
      super.configure()
      
      events.input
         .onSuccess(setState) { .setTitle($0.title) }
         .doMap { $0.pdfName }
         .doNext(works.loadPdfPolicyForName)
         .onSuccess(setState) { .presentPdfDocument($0) }
   }
}
