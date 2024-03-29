//
//  ChallengeResultScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.10.2022.
//

import StackNinja

struct ChallengeResultEvents : ScenarioEvents {   
   let saveInput: Out<Int>
   let commentInputChanged: Out<String>
   let sendResult: Out<Void>
}

final class ChallengeResultScenario<Asset: AssetProtocol>: BaseWorkableScenario<ChallengeResultEvents, ChallengeResultSceneState, ChallengeResultWorks<Asset>> {

   override func configure() {
      super.configure()
      
      events.commentInputChanged
         .doNext(works.inputTextCacher)
         .onSuccess(setState) { .setInputText($0) }
         .doNext(works.reasonInputParsing)
         .onSuccess(setState, .sendingEnabled)
         .onFail(setState, .sendingDisabled)
      
      events.saveInput
         .doNext(works.saveId)
      
      events.sendResult
         .onSuccess(setState, .uploading)
         .onFail(setState) { .error }
         .onSuccess(setState, .sendingDisabled)
         .doNext(works.createChallengeReport)
         .onSuccess(setState) { .finishWithSentResult }
         .onFail(setState) { .error }
   }
}

