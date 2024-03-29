//
//  StickerGalleryVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.02.2023.
//

import StackNinja
import UIKit

struct StickerGalleryEvents: InitProtocol {
   var didClose: Void?
   var didSelectStickerIndex: (UIImage, Int)?
}

final class StickerGalleryVM<Asset: ASP>: ModalDoubleStackModel<Asset>, Eventable {
   typealias Events = StickerGalleryEvents
   var events: EventsStore = .init()

   private lazy var stickerScrollModel = ScrollStackedModelX()
      .spacing(16)
      .hideHorizontalScrollIndicator()

   private var stickerModels: [ImageViewModel] = []

   override func start() {
      super.start()

      title.text(Design.text.chooseSticker)
      closeButton.on(\.didTap, self) {
         $0.send(\.didClose)
      }

      footerStack
         .backColor(Design.color.background)
         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusBig)
         .padding(.bottom(48))
         .disableBottomRadius(Design.params.cornerRadiusBig)
         .arrangedModels(stickerScrollModel)
   }
}

enum StickerGalleryState {
   case setPlaceholdersForStickersCount(Int)
   case addStickerImage(UIImage, Int)
   case clearFromStickers
}

extension StickerGalleryVM: StateMachine {
   func setState(_ state: StickerGalleryState) {
      switch state {
      case let .setPlaceholdersForStickersCount(count):
         let height = 180.0
         let width = 110.0

         for _ in 0 ..< count {
            let imageVM = ImageViewModel()
               .height(height)
               .width(width)
               .contentMode(.scaleAspectFill)
               .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusMini)
               .presentActivityModel(ActivityIndicator<Design>())
               .borderColor(Design.color.iconMidpoint)
               .borderWidth(1)

            stickerModels.append(imageVM)
            stickerScrollModel.addArrangedModels(imageVM)
         }
      case let .addStickerImage(image, index):
         let height = 180.0
         let coef = image.size.width / image.size.height
         let width = height * coef
         stickerModels[index]
            .image(image)
            .height(height)
            .width(width)
            .hideActivityModel()
            .makeTappable()
            .on(\.didTap, self) {
               $0.send(\.didSelectStickerIndex, (image, index))
            }
      case .clearFromStickers:
         stickerScrollModel.arrangedModels([])
      }
   }
}
