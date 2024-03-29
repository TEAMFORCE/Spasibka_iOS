//
//  PickedImagePanel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.09.2022.
//

import Alamofire
import AlamofireImage
import StackNinja
import UIKit

struct PickedImagePanelEvents: InitProtocol {
   var didCloseImage: UIImage?
   var didCloseSticker: UIImage?
   var didCloseImageAtIndex: Int?

   var didMaximumImagesReached: Void?
   var didMaximumStickersReached: Void?
}


final class PickedImagePanel<Design: DSP>: ScrollStackedModelX, Designable, Eventable2 {
   typealias Events2 = PickedImagePanelEvents
   var events2 = EventsStore()

   private var pickedImages = [Int: UIViewModel]()
   private var pickedStickers = [Int: UIViewModel]()

   private var maxImagesCount = 1
   private var maxStickersCount = 1

   override func start() {
      super.start()
      stack.spacing(8)
   }

   func addImageURLs(_ imageURLs: [String]) {
      guard pickedImages.count < maxImagesCount else { return }

      let imageModels = imageURLs.enumerated().map { index, _ in
         let pickedImage = PickedImage<Design>()
            .backColor(Design.color.iconMidpoint)
            .setNeedsStoreModelInView()
            .presentActivityModel(ActivityIndicator<Design>())

         self.pickedImages[index] = pickedImage

         pickedImage.closeButton.on(\.didTap) { [weak self, pickedImage] in
            guard let self = self else { return }

            self.send(\.didCloseImageAtIndex, index)
            pickedImage.uiView.removeFromSuperview()
            self.pickedImages[index] = nil
         }

         return pickedImage
      }

      loadingURLsChainWork
         .doAsync(imageURLs)
         .onEachResult { image, index in
            let imageModel = imageModels[safe: index]
            imageModel?.image.image(image)
            imageModel?.hideActivityModel()
         }

      addArrangedModels(imageModels)
   }

   private let loadingURLsChainWork = GroupWork<String, UIImage> { work in
//      guard let self = self else { return }

      AF
         .request(work.in)
         .responseImage { response in
            switch response.result {
            case let .success(image):
               work.success(image)
            case .failure:
               work.fail()
            }
         }
   }

   func addImage(_ image: UIImage) {
      guard pickedImages.count < maxImagesCount else { return }

      let pickedImage = PickedImage<Design>()
         .backColor(Design.color.iconMidpoint)
      pickedImages[image.hashValue] = pickedImage
      pickedImage.image.image(image)

      addArrangedModels(pickedImage)

      pickedImage.closeButton.on(\.didTap) { [weak self] in
         guard let self = self else { return }
         self.send(\.didCloseImage, image)
         let model = self.pickedImages[image.hashValue]
         model?.uiView.removeFromSuperview()
         self.pickedImages[image.hashValue] = nil
      }

      if pickedImages.count >= maxImagesCount {
         send(\.didMaximumImagesReached)
      }
   }

   func addSticker(_ image: UIImage) {
      guard pickedStickers.count < maxStickersCount else { return }

      let pickedImage = PickedImage<Design>()
      pickedStickers[image.hashValue] = pickedImage
      pickedImage.image.image(image)

      addArrangedModels(pickedImage)

      pickedImage.closeButton.on(\.didTap) { [weak self] in
         guard let self = self else { return }

         self.send(\.didCloseSticker, image)
         let model = self.pickedStickers[image.hashValue]
         model?.uiView.removeFromSuperview()
         self.pickedStickers[image.hashValue] = nil
      }

      if pickedStickers.count >= maxStickersCount {
         send(\.didMaximumStickersReached)
      }
   }

   func clear() {
      pickedImages.removeAll()
      pickedStickers.removeAll()
      arrangedModels([])
   }

   @discardableResult
   func maximumImagesCount(_ value: Int) -> Self {
      maxImagesCount = value
      return self
   }

   @discardableResult
   func maximumStickersCount(_ value: Int) -> Self {
      maxStickersCount = value
      return self
   }
}

protocol CarouselCellProtocol: UIViewModel {
   var closeButton: ButtonModel { get }
}

final class PickedImage<Design: DSP>: StackModel, CarouselCellProtocol, Designable {
   let closeButton = ButtonModel()
      .image(Design.icon.cross.withTintColor(.white))
      .size(.square(23))

   let image = ImageViewModel()
      .size(.square(Grid.x80.value))
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)

   init(imageUrl: String) {
      super.init()
      setNeedsStoreModelInView()
      presentActivityModel(ActivityIndicator<Design>())
      
      image.indirectUrl(imageUrl) { [weak self] _, _ in
         self?.hideActivityModel()
      }
   }
   
   init(image: UIImage) {
      super.init()
      self.image.image(image)
   }

   required init() {
      super.init()
      //assertionFailure()
   }

   override func start() {
      super.start()
      backColor(Design.color.background)
      axis(.horizontal)
      alignment(.top)
      size(.square(Grid.x80.value))
      clipsToBound(true)
      cornerRadius(Design.params.cornerRadius)
      cornerCurve(.continuous)
      arrangedModels([
         Grid.xxx.spacer,
         closeButton,
      ])
      backViewModel(image)
   }
}
