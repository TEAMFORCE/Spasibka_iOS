//
//  BenefitCell.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 13.01.2023.
//

import StackNinja
import UIKit

final class BenefitCell<Design: DSP>: StackModel, Designable {
   private(set) lazy var titleLabel = LabelModel()
      .set(Design.state.label.semibold14)
      .textColor(Design.color.textInvert)
      .numberOfLines(2)

   private(set) lazy var descriptionLabel = LabelModel()
      .set(Design.state.label.regular14)
      .textColor(Design.color.textInvert)
      .numberOfLines(2)

   private(set) lazy var backImage = ImageViewModel()
      .backColor(Design.color.backgroundBrandSecondary)
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadius)

   private(set) lazy var currencyButton = CurrencyButtonDT<Design>()
      .setMode(\.normal)

   private(set) lazy var pagingImagesModel = PagingScrollViewModel()
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
      .passThroughTouches()
//      .addModel(ViewModel().backColor(.black.withAlphaComponent(0.5))) {
//         $0.fitToView($1)
//      }

   // Work
   private(set) lazy var calculateBrightnessWork = Work<UIImage, CGFloat> {
      let image = $0.unsafeInput

      let coef = image.size.width / image.size.height
      let resizeImageWidth: CGFloat = 24.0
      let resizeHeight = round(resizeImageWidth / coef)
      let resizeSize = CGSize(width: resizeImageWidth, height: resizeHeight)
      let bright = image.resized(to: resizeSize).brightness
      $0.success(bright)
   }

   private(set) lazy var loadImageGroup: GroupWork<String, UIImage> = .init { work in
      let url = work.unsafeInput

      ImageViewModel() // так кэшируется! а так нет: AF.request(url).responseImage
         .indirectUrl(url) { model, image in
            if let image {
               model?.hideActivityModel()
               work.success(image)
            } else {
               work.fail()
            }
         }
   }

   required init() {
      super.init()
      setNeedsStoreModelInView()

      backViewModel(pagingImagesModel.wrappedX().backViewModel(backImage),
                    inset: .verticalOffset(8))
      alignment(.leading)
      padding(.outline(24))
      height(174)

      arrangedModels(
         titleLabel,
         Spacer(4),
         descriptionLabel,
         Spacer(16),
         Spacer(),
         currencyButton,
         Spacer(4)
      )

      pagingImagesModel.on(\.didViewModelPresented, self) { selfy, tuple in
         guard let image = (tuple.0.uiView as? UIImageView)?.image else { return }

         selfy.calculateBrightnessForImage(image)
      }
   }

   private func calculateBrightnessForImage(_ image: UIImage) {
      calculateBrightnessWork
         .doAsync(image, on: .globalBackground)
         .onSuccess(self) {
            if $1 < 0.7 {
               $0.setState(.inverted)
            } else {
               $0.setState(.normal)
            }
         }
   }

   func presentImageUrls(_ urls: [String]) {
      let imageModels = urls.map { _ in
         ImageViewModel {
            $0
               .contentMode(.scaleAspectFill)
               .presentActivityModel(ActivityIndicator<Design>(), centerShift: .init(x: 0, y: 42))
         }
      }

      pagingImagesModel.setState(.setViewModels(imageModels))

      loadImageGroup
         .doAsync(urls)
         .onEachResult { [weak self] image, index in
            guard let models = self?.pagingImagesModel.models as? [ImageViewModel] else { return }

            models[index]
               .image(image, duration: 0.2, transitionType: .fade)
               .hideActivityModel()
               .addModel(ViewModel().backColor(.black.withAlphaComponent(0.5))) {
                  $0.fitToView($1)
               }

//            if index == self?.pagingImagesModel.currentPage {
//               self?.calculateBrightnessForImage(image)
//            }
         }
   }
}

enum BenefitCellState {
   case inverted
   case normal
}

extension BenefitCell: StateMachine {
   func setState(_ state: BenefitCellState) {
      UIView.animate(withDuration: 0.33) {
         switch state {
         case .inverted:
            self.titleLabel.textColor(Design.color.textInvert)
            self.descriptionLabel.textColor(Design.color.textInvert)
            self.currencyButton.setMode(\.normal)
         case .normal:
            self.titleLabel.textColor(Design.color.text)
            self.descriptionLabel.textColor(Design.color.text)
            self.currencyButton.setMode(\.selected)
         }
      }
   }
}
