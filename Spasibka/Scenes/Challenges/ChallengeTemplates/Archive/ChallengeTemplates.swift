//
//  ChallengeTemplates.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.05.2023.
//

import StackNinja

//enum ChallengeTemplates<Asset: ASP>: ScenaribleSceneParams {
//   typealias Scenery = ChallengeTemplatesScenario<Asset>
//   typealias ScenarioWorks = ChallengeTemplatesWorks<Asset>
//
//   struct ScenarioInputEvents: ScenarioEvents {
//      let presentMyTemplates: Out<Void>
//      let presentOursTemplates: Out<Void>
//      let presentCommonTemplates: Out<Void>
//
//      let requestPagination: VoidWork
//
//      let didChangeSearchText: Out<String>
//      let didSelectTemplateAtIndex: Out<Int>
//      let didTapEditTemplateAtIndex: Out<Int>
//
//      let didTapCreateButton: Out<Void>
//
//      let reloadTemplates: VoidWork
//   }
//
//   enum ScenarioModelState {
//      case initial
//      case presentObjects([ChallengeTemplate])
//      case loadingError
//      case presentCreateChallengeWithTemplate(ChallengeTemplate)
//      case presentCreateChallengeTemplate(ChallengeTemplatesScope)
//      case presentUpdateTemplateWithTemplate(ChallengeTemplate, scope: ChallengeTemplatesScope)
//   }
//
//   struct Models: SceneModelParams {
//      typealias VCModel = DefaultVCModel
//      typealias MainViewModel = BrandDoubleStackVM<Asset.Design>
//   }
//
//   struct InOut: InOutParams {
//      typealias Input = Void
//      typealias Output = Void
//   }
//}
