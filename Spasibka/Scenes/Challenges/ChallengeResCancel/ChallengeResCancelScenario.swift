//
//  ChallengeResCancelScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 17.10.2022.
//

import StackNinja

struct ChallengeResCancelEvents: ScenarioEvents {   
   let saveInput: Out<Int>
   let commentInputChanged: Out<String>
   let sendReject: Out<Void>
}

final class ChallengeResCancelScenario<Asset: AssetProtocol>: BaseWorkableScenario<ChallengeResCancelEvents, ChallengeResCancelSceneState, ChallengeResCancelWorks<Asset>> {

   override func configure() {
      super.configure()
      
      events.commentInputChanged
         .doNext(works.reasonInputParsing)
         .onSuccess(setState, .sendingEnabled)
         .onFail(setState, .sendingDisabled)
      
      events.saveInput
         .doNext(works.saveInput)
      
      events.sendReject
         .doNext(works.rejectReport)
         .onSuccess(setState, .finish)
         .onFail {
            print("Обработать ошибку")
         }
      
   }
}

