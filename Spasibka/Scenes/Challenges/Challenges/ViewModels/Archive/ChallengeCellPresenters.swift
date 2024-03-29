//
//  ChallengeCellPresenters.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.11.2022.
//

import StackNinja

struct ChallengeCellPresenters<Design: DSP>: Designable {
   static var presenter: CellPresenterWork<Challenge, ChallengeCell<Design>> { .init { work in
      
      func setBackImage(suffix: String) {
         model.setState(.inverted)
         model.back
            .backColor(Design.color.iconContrast)
            .addModel(
               ViewModel()
                  .backColor(Design.color.iconContrast)
                  .alpha(0.6)
            ) { anchors, view in
               anchors.fitToView(view)
            }
            .indirectUrl(SpasibkaEndpoints.urlBase + suffix) {
               data.photoCache = $1
            }
      }
      
      let data = work.unsafeInput.item

      let model = ChallengeCell<Design>()
         .setAll { infoBlock, statusBlock in
            infoBlock.setAll { title, winner, prizeFund, prizes in

               title.title.text(data.name.unwrap)

               let creatorName = data.creatorName.unwrap
               let creatorSurname = data.creatorSurname.unwrap
               let organizationName = data.organizationName.unwrap
               
               if data.fromOrganization == true {
                  title.body.text(Design.text.fromSpaceAfter + organizationName)
               } else {
                  title.body.text(Design.text.fromSpaceAfter + creatorName + " " + creatorSurname)
               }

               let winnersCount = data.winnersCount ?? 0
               winner.title.text(winnersCount.toString)
               winner.body.text(Design.text.winnersCount)

               prizeFund.title.text(data.fund.toString)
               prizeFund.body.text(Design.text.prizeFund)

               prizes.title.text(data.awardees.toString)
               prizes.body.text(Design.text.awardeesCount)
            }

            let updatedDateString = data.updatedAt.unwrap.dateFormatted(.ddMMyyyy)
            switch data.challengeCondition {
            case .A:
               statusBlock.statusLabel.text(Design.text.active)
               statusBlock.statusLabel.textColor(Design.color.success)
               statusBlock.statusLabel.backColor(Design.color.successSecondary )
            case .F:
               statusBlock.statusLabel.text(Design.text.completed)
            case .D, .W:
               statusBlock.statusLabel.text(Design.text.deferred)
            case .C:
               statusBlock.statusLabel.backColor(Design.color.iconMidpoint)
               statusBlock.statusLabel.text(Design.text.cancelled)
            case .none:
               break
            }
            statusBlock.dateLabel.text(Design.text.updated + updatedDateString.unwrap)
            statusBlock.backImage
               .image(Design.icon.challengeWinnerIllustrate)
               .contentMode(.scaleAspectFit)
         }
            
      if let suffix = data.photo {
         setBackImage(suffix: suffix)
      }
      
      if let photosSuffix = data.photos?.first {
         setBackImage(suffix: photosSuffix)
      }

      work.success(model)
   } }
}
