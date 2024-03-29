//
//  BenefitBasketCell.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 13.02.2024.
//

import StackNinja

final class BenefitBasketCell<Design: DSP>: StackModel {
   var deleteButton: ButtonModel { deleteButton1 }
   var countPlusButton: ButtonModel { countSelectorModel.plusButton }
   var countMinusButton: ButtonModel { countSelectorModel.minusButton }
   var checkMark: CheckMarkModel<Design> { checkMarkModel }
   
   // Private
   private lazy var checkMarkModel = CheckMarkModel<Design>()
      .size(.square(14))

   private lazy var iconModel = ImageViewModel()
      .size(.square(100))
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
      .backColor(Design.color.backgroundBrandSecondary)
      .contentMode(.scaleAspectFill)
      .image(Design.icon.tablerBriefcase.insetted(12).withTintColor(Design.color.iconBrand))

   private lazy var countSelectorModel = CountSelectorVM<Design>()
   
   let titleLabel = LabelModel()
      .numberOfLines(3)
      .set(Design.state.label.descriptionMedium14)
   
   let deleteButton1 = ButtonModel()
      .image(Design.icon.trash.resized(to: .square(16)), color: Design.color.iconContrast)
   
   private lazy var firstStack = StackModel()
      .axis(.horizontal)
      .alignment(.leading)
      .distribution(.fill)
      .spacing(4)
      .arrangedModels([
         titleLabel,
         Grid.xxx.spacer,
         deleteButton1
      ])
   
   private lazy var priceModel = NewCurrencyLabelDT<Design>()
      .setAll { image, _, label in
         label
            .font(Design.font.descriptionMedium18)
         image
            .image(Design.icon.smallSpasibkaLogo)
            .imageTintColor(Design.color.text)
            .size(.init(width: 17.45, height: 14))
      }
      .height(24)
      .spacing(2.5)
   
   private lazy var secondStack = StackModel()
      .axis(.horizontal)
      .alignment(.leading)
      .distribution(.fill)
      .spacing(4)
      .arrangedModels([
         countSelectorModel,
         Grid.xxx.spacer,
         priceModel
      ])
   
   private lazy var infoBlock = StackModel()
      .axis(.vertical)
      .spacing(6)
      .arrangedModels([
         firstStack,
         Grid.xxx.spacer,
         secondStack
      ])
      .height(100)
   
   required init() {
      super.init()

      setNeedsStoreModelInView()

      axis(.horizontal)
      alignment(.center)
      spacing(16)
      padVertical(24)

      arrangedModels([
         checkMarkModel,
         iconModel,
         infoBlock
      ])
   }
}

enum BenefitBasketCellState {
   case item(CartItem)
   case awaiting
}

extension BenefitBasketCell: StateMachine {
   func setState(_ state: BenefitBasketCellState) {
      switch state {
      case let .item(item):
         
         var showcaseImage: String?
         if let image = item.presentingImages?.first(where: {
            $0.forShowcase == true
         }) {
            showcaseImage = image.link
         }
         
         titleLabel.text(item.name.unwrap)
         priceModel.label.text(item.price?.toString ?? "")
         
         checkMarkModel.setState(item.isChosen ?? false)
         iconModel.url(showcaseImage)
         countSelectorModel.quantity.text(String(item.quantity ?? 0))
         
         if let imageUrls = item.images?.compactMap(\.link), let firstUrl = imageUrls.first {
            iconModel.indirectUrl(SpasibkaEndpoints.urlBase + firstUrl)
         }

      case .awaiting:
         alpha(0.5)
         presentActivityModel(ActivityIndicator<Design>())
         userInterractionEnabled(false)
      }
   }
}
