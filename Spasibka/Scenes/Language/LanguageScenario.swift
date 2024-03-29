//
//  LanguageScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2023.
//

import StackNinja
import UIKit

struct LanguageScenarioEvents: ScenarioEvents {
   let setEnglish: VoidWork
   let setRussian: VoidWork
   let changeLanguage: Out<AppLanguages>
}

struct LanguageScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = LanguageScenarioEvents
   typealias ScenarioModelState = LanguageSceneState
   typealias ScenarioWorks = LanguageWorks<Asset>
}

final class LanguageScenario<Asset: ASP>: BaseParamsScenario<LanguageScenarioParams<Asset>> {
   override func configure() {
      super.configure()
      
      events.setEnglish
         .onSuccess(setState, .showAlert(.en))
      
      events.setRussian
         .onSuccess(setState, .showAlert(.ru))
      
      events.changeLanguage
         .doNext(works.changeLanguage)
         .onSuccess {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let delegate = scene?.delegate as? SceneDelegate
            delegate?.reload()
         }
   }
}
