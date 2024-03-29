//
//  PhotosGalleryMini.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 15.03.2023.
//

import StackNinja

final class PhotosGalleryMini<Design: DSP>: Stack<LabelModel>.D<ScrollStackedModelX>.Ninja, Eventable {
   struct Events: InitProtocol {
      var didTapImageUrlString: (String, Int?)?
   }
   
   var events: EventsStore = .init()
   
   required init() {
      super.init()
      
      setAll {
         $0
            .padBottom(10)
            .set(Design.state.label.labelRegular14)
            .text(Design.text.attachments)
         $1
            .spacing(8)
            .height(130)
      }
   }
   
   func addPhoto(url: String) {
      let imageModel = ImageViewModel()
         .image(Design.icon.transactSuccess)
         .height(130)
         .width(130)
         .contentMode(.scaleAspectFill)
         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
         .presentActivityModel(ActivityIndicator<Design>())
         .backColor(Design.color.backgroundSecondary)
         .indirectUrl(url) { model, _ in
            model?.hideActivityModel()
         }
      imageModel.setNeedsStoreModelInView()
      
      imageModel.view.startTapGestureRecognize()
      imageModel.view.on(\.didTap, self) {
         let index: Int? = self.models.down.stack.view.arrangedSubviews.firstIndex(of: imageModel.uiView)
         $0.send(\.didTapImageUrlString, (url, index))
      }
      models.down.addArrangedModels(imageModel)
   }
   
   func clear() {
      models.down.arrangedModels([])
   }
}
