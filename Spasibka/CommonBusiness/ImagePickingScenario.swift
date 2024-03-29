//
//  ImagePickingScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 05.09.2022.
//

import UIKit
import StackNinja

enum ImagePickingState {
   case presentImagePicker
   case presentImagePickerWithLimit(limit: Int)
   case presentPickedImage(UIImage)
   case setHideAddPhotoButton(Bool)
   case setHidePanel(Bool)
}

struct ImagePickingScenarioEvents: ScenarioEvents {   
   let startImagePicking: VoidWork
   let addImageToBasket: Out<UIImage>
   let removeImageFromBasket: Out<UIImage>
   let didMaximumReach: Out<Void>
}

final class ImagePickingScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<ImagePickingScenarioEvents, ImagePickingState, ImageWorks>
{
   
   override func configure() {
      super.configure()
      
      let basketLimit = 10
      events.startImagePicking
         .doNext(works.getSelectedCount)
         .doMap { 
           return basketLimit - $0 
         }
         .onSuccess(setState) { .presentImagePickerWithLimit(limit: $0) }
         .onSuccess(setState, .presentImagePicker) // alternative 
      
      events.addImageToBasket
         .doNext(works.addImage)
         .onSuccess(setState) { .presentPickedImage($0) }
      
      events.removeImageFromBasket
         .doNext(works.removeImage)
         .doVoidNext(works.checkIsFull)
         .onSuccess(setState) { .setHideAddPhotoButton($0) }
         .doVoidNext(works.checkIsEmpty)
         .onSuccess(setState) { .setHidePanel($0) }

      events.didMaximumReach
         .onSuccess(setState, .setHideAddPhotoButton(true))
   }
}
