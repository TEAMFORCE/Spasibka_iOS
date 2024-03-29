//
//  ChallengeCell.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.11.2022.
//

import StackNinja

final class ChallengeCell<Design: DSP>:
   Stack<ChallengeCellInfoBlock>.R<ChallengeCellStatusBlock<Design>>.Ninja, Designable
{
   lazy var back = ImageViewModel()
      .backColor(Design.color.backgroundBrandSecondary)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)

   required init() {
      super.init(isAutoreleaseView: true)

      setAll { infoBlock, _ in
         infoBlock.setAll { title, winner, prizeFund, prizes in
            title.title
               .set(Design.state.label.medium16)
               .numberOfLines(2)
               .lineBreakMode(.byWordWrapping)
            title.body.set(Design.state.label.regular12)

            winner.title.set(Design.state.label.bold14)
            winner.body.set(Design.state.label.regular12)

            prizeFund.title.set(Design.state.label.bold14)
            prizeFund.body.set(Design.state.label.regular12)

            prizes.title.set(Design.state.label.bold14)
            prizes.body.set(Design.state.label.regular12)
         }
         .alignment(.leading)
         .padding(.right(-70))
      }
      height(224)
      padding(.init(top: 20, left: 16, bottom: 20, right: 16))
      backViewModel(back, inset: .verticalOffset(4))
   }
}

enum ChallengeCellState {
   case inverted
}

extension ChallengeCell: StateMachine {
   func setState(_ state: ChallengeCellState) {
      switch state {
      case .inverted:
         setAll { infoBlock, statusBlock in
            infoBlock.setAll { title, winner, prizeFund, prizes in
               title.title.textColor(Design.color.textInvert)
               title.body.textColor(Design.color.textInvert)

               winner.title.textColor(Design.color.textInvert)
               winner.body.textColor(Design.color.textInvert)

               prizeFund.title.textColor(Design.color.textInvert)
               prizeFund.body.textColor(Design.color.textInvert)

               prizes.title.textColor(Design.color.textInvert)
               prizes.body.textColor(Design.color.textInvert)
            }

            statusBlock.backImage.hidden(true)
            statusBlock.dateLabel
               .backColor(Design.color.transparent)
               .textColor(Design.color.textInvert)
               .borderColor(Design.color.textInvert)
         }
      }
   }
}
