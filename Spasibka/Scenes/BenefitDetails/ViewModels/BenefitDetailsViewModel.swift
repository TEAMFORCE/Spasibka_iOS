//
//  BenefitDetailsViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 17.01.2023.
//

import StackNinja

struct BenefitDetailsVMEvents: InitProtocol {}

final class BenefitDetailsViewModel<Design: DSP>: ScrollStackedModelY, Designable {
   private lazy var benefitInfo = BenefitInfoVM<Design>()

   private lazy var leftAmountInfoBlock = ChallengeChainCardInfoVM<Design> {
      $0.headerVM
         .image(Design.icon.clock.withTintColor(Design.color.iconContrast))
      $0.headerVM
         .text(Design.text.restAmount)
      $0.caption
         .text("0")
   }

   private lazy var purchasedInfoBlock = ChallengeChainCardInfoVM<Design> {
      $0.headerVM
         .image(Design.icon.gift.withTintColor(Design.color.iconBrand))
      $0.headerVM
         .text(Design.text.purchased)
      $0.caption
         .text("0")
   }

   private lazy var selectedAmountInfoBlock = ChallengeChainCardInfoVM<Design> {
      $0.headerVM
         .image(Design.icon.clock.withTintColor(Design.color.iconContrast))
      $0.headerVM
         .textUnedited(Design.text.selectedAmount)
      $0.caption
         .text("0")
      $0.padRight(12)
      $0.spacing(10)
   }
   
   private lazy var descriptionLabel = LabelModel()
      .font(Design.font.descriptionRegular12)
      .numberOfLines(0)
      .textColor(Design.color.text)
   
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
   
   private lazy var titleLabel = LabelModel()
      .font(Design.font.descriptionMedium20)
      .numberOfLines(0)
      .textColor(Design.color.text)
   
   private lazy var titleStack = StackModel()
      .axis(.horizontal)
      .alignment(.leading)
      .distribution(.fill)
      .arrangedModels([
         titleLabel,
         Spacer(),
         priceModel
      ])

   
   override func start() {
      super.start()

      spacing(8)
         .bounce(true)
         .arrangedModels([
//            benefitInfo,
            titleStack,
            Spacer(16),
            HStackModel(leftAmountInfoBlock, purchasedInfoBlock, selectedAmountInfoBlock)
               .spacing(8),
            Spacer(16),
            descriptionLabel,
//            leftAmountCell,
//            selectedAmountCell,
            Spacer(16),
         ])
         .hideVerticalScrollIndicator()
         .set(.padding(.init(top: 20, left: 0, bottom: 16, right: 0)))
         .view.alwaysBounceVertical = true
   }
}

extension BenefitDetailsViewModel {
   typealias Events = BenefitDetailsVMEvents
}

enum BenefitDetailsViewModelState {
   case presentBenefit(Benefit)
   case updateDetails(Benefit)
}

extension BenefitDetailsViewModel: StateMachine {
   func setState(_ state: BenefitDetailsViewModelState) {
      switch state {
      case let .presentBenefit(benefit):
         benefitInfo.setup(benefit)
         
         leftAmountInfoBlock.models.down
            .text((benefit.rest?.toString ?? "") + Design.text.units)
         
         purchasedInfoBlock.models.down
            .text((benefit.sold?.toString ?? "") + Design.text.units)
         
         selectedAmountInfoBlock.models.down
            .text((benefit.selected?.toString ?? "") + Design.text.units)
         
         descriptionLabel.text(benefit.description.unwrap)
         titleLabel.text(benefit.name.unwrap)
         priceModel.label.text(benefit.price?.priceInThanks?.toString ?? "")

      case let .updateDetails(benefit):
         setState(.presentBenefit(benefit))
      }
   }
}

final class BenefitDetailsInfoCell<Design: DSP>:
   Stack<LabelModel>.R<Spacer>.R2<LabelModel>.Ninja,
   Designable
{
   required init() {
      super.init()

      setAll { title, _, status in
         title
            .set(Design.state.label.regular14)
         status
            .set(Design.state.label.regular14brand)
            .backColor(Design.color.background)
            .alignment(.center)
            .height(36)
            .width(65)
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
      }
      .backColor(Design.color.backgroundInfoSecondary)
      .height(60)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
      .spacing(12)
      .alignment(.center)
      .padding(.horizontalOffset(16))
   }
}
