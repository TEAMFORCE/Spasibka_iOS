//
//  ChallengeChainHeaderVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.01.2024.
//

import StackNinja
import UIKit

final class ChallengeChainHeaderVM<Design: DSP>: VStackModel, Eventable {
   struct Events: InitProtocol {
      var didImagePresented: (image: UIImage, backColor: UIColor?)?
      var pressedImagePath: String?
   }

   var events: EventsStore = .init()

   let headerStackBackColor: UIColor

   private(set) lazy var pagingImagesVM = PagingImagesHeaderVM<Design>()
      .backImage(defaultHeaderImage)
      .on(\.didImagePresented, self) { slf, image in
         slf.send(\.didImagePresented, (image: image, backColor: nil))
      }

   private var bufferedImage: UIImage?
   private let defaultHeaderImage: UIImage

   init(placeholder: UIImage, backColor: UIColor) {
      headerStackBackColor = backColor
      defaultHeaderImage = placeholder
      super.init()
   }

   required init() {
      fatalError("init() has not been implemented")
   }

   override func start() {
      super.start()

      arrangedModels(pagingImagesVM)
      send(\.didImagePresented, (image: defaultHeaderImage, backColor: headerStackBackColor))
   }

   @discardableResult
   func headerImage(_ image: UIImage) -> Self {
      bufferedImage = image
      pagingImagesVM.addViewModel(
         ImageViewModel()
            .contentMode(.scaleAspectFill)
            .image(image)
            .presentActivityModel(ActivityIndicator<Design>())
      )
      send(\.didImagePresented, (image: image, backColor: headerStackBackColor))
      return self
   }

   @discardableResult
   func presentIndirectUrls(_ urls: [String], placeHolder: UIImage? = nil) -> Self {
      pagingImagesVM.presentIndirectUrls(urls, placeHolder: placeHolder ?? bufferedImage)
      pagingImagesVM
         .on(\.pressedImagePath, self) {
            $0.send(\.pressedImagePath, $1)
         }
      return self
   }

   @discardableResult
   func updateHeaderImages(photoUrls: [String]?, photoUrl: String? = nil) -> Out<String> {
      let urls = photoUrls ?? [photoUrl].compactMap { $0 }
      presentIndirectUrls(urls.map(SpasibkaEndpoints.convertToImageUrl))
      return on(\.pressedImagePath)
   }
}
