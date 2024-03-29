//
//  AvatarPickingScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 11.09.2022.
//

import UIKit
import StackNinja

struct AvatarPickingScenarioEvents: ScenarioEvents {   
   let startImagePicking: VoidWork
   let addImageToBasket: Out<UIImage>
   let saveCroppedImage: Out<UIImage>
}

final class AvatarPickingScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<
      AvatarPickingScenarioEvents,
      AvatarPickingState,
      MyProfileWorks<Asset>
   >
{
   override func configure() {
      super.configure()
      
      events.startImagePicking
         .onSuccess(setState, .presentImagePicker)

      events.addImageToBasket
         .doNext(works.addImage)
         .onSuccess(setState) { .presentPickedImage($0) }

      events.saveCroppedImage
         .doNext(works.saveCroppedImage)
         .onSuccess(setState) {
            .presentPickedImage($0)
         }
         .doVoidNext(works.getStoredUserData)
         .doNext(works.updateAvatarForUserData)
   }
}
