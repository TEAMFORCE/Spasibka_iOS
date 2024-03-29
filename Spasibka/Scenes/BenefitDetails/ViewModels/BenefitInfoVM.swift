//
//  BenefitInfoVM.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 17.01.2023.
//

import StackNinja

final class BenefitInfoVM<Design: DSP>: StackModel, Designable {
   lazy var title = Design.label.regular20
      .numberOfLines(0)
      .font(.systemFont(ofSize: 20, weight: .bold))
   
   lazy var deadlineBlock = BenefitInfoBlock<Design>()
      .setAll { title, body in
         title.text(Design.text.validity)
         body.text("")
      }
   
   lazy var descriptionBlock = BenefitInfoBlock<Design>()
      .setAll { title, body in
         title.text(Design.text.description)
         body.lineSpacing(8)
      }
   
   lazy var priceBlock = BenefitInfoBlock<Design>()
      .setAll { title, body in
         title.text(Design.text.price)
         body.text("")
      }

   override func start() {
      super.start()

      arrangedModels([
         title,
         Spacer(20),
         deadlineBlock,
         Spacer(20),
         descriptionBlock,
         Spacer(20),
         priceBlock
      ])
      backColor(Design.color.background)
      distribution(.equalSpacing)
      alignment(.leading)
   }
}

extension BenefitInfoVM: SetupProtocol {
   func setup(_ data: Benefit) {
      title.text(data.name.unwrap)
      let deadlineText = data.actualTo == nil ? Design.text.notLimited : ""
      deadlineBlock.models.down.text(deadlineText)
      descriptionBlock.models.down.text(data.description.unwrap)

      guard let price = data.price?.priceInThanks else {
         priceBlock.models.down.text("")
         return
      }

      let priceText = Design.text.pluralCurrencyWithValue(price, case: .genitive)
      priceBlock.models.down.text(priceText)
   }
}

struct BenefitInfoBlockData {
   let text1: String
   let text2: String
}

final class BenefitInfoBlock<Design: DSP>:
   Stack<LabelModel>.D<LabelModel>.Ninja,
   Designable
{
   required init() {
      super.init()

      setAll { title, body in
         title
            .set(Design.state.label.bold14)
         body
            .set(Design.state.label.regular14)
            .textColor(Design.color.textSecondary)
            .numberOfLines(0)
      }
      .spacing(8)
   }
}

extension BenefitInfoBlock: StateMachine {
   func setState(_ state: BenefitInfoBlockData) {
      models.main.text(state.text1)
      models.down.text(state.text2)
   }
}

