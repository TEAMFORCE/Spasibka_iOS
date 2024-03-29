//
//  ProfileScenesParams.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.12.2022.
//

import StackNinja
import UIKit

typealias ProfileID = Int

struct MyProfileSceneParams<Asset: AssetProtocol>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyFooterStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = ProfileID
      typealias Output = UIImage
   }
}
