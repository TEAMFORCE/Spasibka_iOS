//
//  ChallReportDetailScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.10.2022.
//

import StackNinja

struct ChallReportDetailsEvents : ScenarioEvents {   
   let saveInput: Out<Int>
   let presentImage: Out<String>
}

final class ChallReportDetailsScenario<Asset: AssetProtocol>: BaseWorkableScenario<ChallReportDetailsEvents, ChallReportDetailsSceneState, ChallReportDetailsWorks<Asset>> {

   override func configure() {
      super.configure()
      
      events.saveInput
         .doNext(works.getChallengeReportById)
         .onSuccess(setState) { .presentReportDetail($0) }
         .onFail { print("fail") }
      
      events.presentImage
         .onSuccess {
            Asset.router?.route(.presentModallyOnPresented(.automatic),
                                scene: \.imageViewer,
                                payload: $0)
         }
   }
}
