//
//  ChallengeNewCellInfoBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.01.2024.
//

import StackNinja

// MARK: - ChallengeNewCellInfoBlock

final class ChallengeNewCellInfoBlock<Design: DSP>: VStackModel {
   private lazy var dateLabel = LabelModel()
      .set(Design.state.label.medium12)
      .textColor(Design.color.textSecondary)

   private lazy var infoBlock = Wrapped3X<InfoTitleBodyY, InfoTitleBodyY, InfoTitleBodyY>()
      .distribution(.fillEqually)

   override func start() {
      super.start()

      arrangedModels(
         dateLabel,
         infoBlock
      )
      spacing(12)
      padding(.init(top: 12, left: 16, bottom: 20, right: 16))
   }
}

extension ChallengeNewCellInfoBlock: StateMachine {
   struct ModelState {
      let updateDate: String
      let title1: String
      let subtitle1: String
      let title2: String
      let subtitle2: String
      let title3: String
      let subtitle3: String
   }

   func setState(_ state: ModelState) {
      dateLabel.text(Design.text.updated + "\(state.updateDate)")
      infoBlock.model1
         .setAll { title, icon, body in
            title.text(state.title1)
            icon.image(Design.icon.smallSpasibkaLogo, color: Design.color.iconBrand)
            body.text(state.subtitle1)
         }

      infoBlock.model2
         .setAll { title, icon, body in
            title.text(state.title2)
            icon.image(Design.icon.tablerAward, color: Design.color.iconBrand)
            body.text(state.subtitle2)
         }

      infoBlock.model3
         .setAll { title, icon, body in
            title.text(state.title3)
            icon.image(Design.icon.tablerGift, color: Design.color.iconBrand)
            body.text(state.subtitle3)
         }
   }
}

private extension ChallengeNewCellInfoBlock {
   final class InfoTitleBodyY: Stack<LabelModel>.R<ImageViewModel>.LD<LabelModel>.Ninja {
      var title: LabelModel { models.main }
      var icon: ImageViewModel { models.right }
      var body: LabelModel { models.leftDown }

      required init() {
         super.init()

         alignment(.leading)
         setAll { title, icon, body in
            title
               .set(Design.state.label.descriptionMedium16)
               .textColor(Design.color.text)
               .numberOfLines(1)
               .alignment(.left)
               .padRight(4)
               .height(22)

            icon
               .size(.square(16))

            body
               .set(Design.state.label.descriptionRegular12)
               .textColor(Design.color.text)
               .numberOfLines(1)
               .alignment(.left)
               .height(20)
         }
      }
   }
}
