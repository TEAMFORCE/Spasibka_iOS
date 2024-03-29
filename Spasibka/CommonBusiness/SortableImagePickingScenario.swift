//
//  SortableImagePickingScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 26.10.2023.
//

import UIKit
import StackNinja

enum SortableImagePickingState {
   case presentImagePicker
   case presentImagePickerWithLimit(limit: Int)
   case presentPickedImage(UIImage)
   case setHideAddPhotoButton(Bool)
   case setHidePanel(Bool)
}

struct SortableImagePickingScenarioEvents: ScenarioEvents {
   let startImagePicking: VoidWork
   let addImageToBasket: Out<UIImage>
   let removeImageFromBasketAtIndex: Out<Int>
   let moveImage: Out<(from: Int, to: Int)>
   let didMaximumReach: Out<Void>
}

final class SortableImagePickingScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<SortableImagePickingScenarioEvents, SortableImagePickingState, SortableImageWorks>
{
   
   override func configure() {
      super.configure()
      
      events.startImagePicking
         .doMap(works.getImagesCountLeft)
         .onSuccess(setState) { .presentImagePickerWithLimit(limit: $0) }
         .onSuccess(setState, .presentImagePicker)
      
      events.addImageToBasket
         .doMap(works.addImage)
         .onSuccess(setState) { .presentPickedImage($0) }
         .doInput(())
         .doMap(works.checkIsFull)
         .onSuccess(setState) { .setHideAddPhotoButton($0) }
      
      events.removeImageFromBasketAtIndex
         .doMap(works.removeImageAtIndex)
         .doMap(works.checkIsFull)
         .onSuccess(setState) { .setHideAddPhotoButton($0) }
      
      events.didMaximumReach
         .onSuccess(setState) { .setHideAddPhotoButton(true) }
      
      events.moveImage
         .doMap(works.moveImage)
   }
}

