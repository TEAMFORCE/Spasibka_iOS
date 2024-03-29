//
//  EditLocationsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.12.2022.
//

import StackNinja

struct EditLocationSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = ModalDoubleStackModel<Asset>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

final class EditLocationScene<Asset: ASP>: BaseParamsScene<EditLocationSceneParams<Asset>> {
   override func start() {
      
   }
}
