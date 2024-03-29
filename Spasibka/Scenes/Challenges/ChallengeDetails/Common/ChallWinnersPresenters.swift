//
//  ChallWinnersPresenters.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.10.2022.
//

import StackNinja
import UIKit

class ChallWinnersPresenters<Design: DesignProtocol>: Designable {
    var events: EventsStore = .init()
   
   var winnersCellPresenter: CellPresenterWork<ChallengeWinnerReport, WrappedX<StackModel>> {
      CellPresenterWork { work in
         let index = work.unsafeInput.indexPath.row
         let winnerReport = work.unsafeInput.item
         let awardedAt = winnerReport.awardedAt
         let nickname = winnerReport.nickname.unwrap
         let name = winnerReport.participantName.unwrap
         let surname = winnerReport.participantSurname.unwrap
         let award = winnerReport.award ?? 0

         let icon = ImageViewModel()
            .contentMode(.scaleAspectFill)
            .image(Design.icon.newAvatar)
            .size(.square(Grid.x36.value))
            .cornerCurve(.continuous)
            .cornerRadius(Grid.x36.value / 2)
         
         let nicknameLabel = LabelModel()
            .text("@" + nickname)
            .set(Design.state.label.bold14)
         
         let awardedLabel = LabelModel()
            .text(awardedAt.dateFullConverted)
            .set(Design.state.label.regular12)
         
         let receivedLabel = LabelModel()
            .set(Design.state.label.bold14)
            .text(Design.text.pluralCurrencyWithValue(award, case: .genitive))
            .textColor(Design.color.success)

         if let avatar = winnerReport.participantPhoto {
            icon.url(SpasibkaEndpoints.urlBase + avatar)
         } else {
            let userIconText =
            String(name.first ?? "?") +
            String(surname.first ?? "?")
            DispatchQueue.global(qos: .background).async {
               let image = userIconText.drawImage(backColor: Design.color.backgroundBrand)
               DispatchQueue.main.async {
                  icon
                     .backColor(Design.color.backgroundBrand)
                     .image(image)
               }
            }
         }
         
         let messageButton = ReactionButton<Design>()
            .setAll {
               $0.image(Design.icon.messageCloud)
               $1.text(String(winnerReport.commentsAmount ?? 0))
            }

         let likeButton = ReactionButton<Design>()
            .setAll {
               $0.image(Design.icon.like)
               $1.text(String(winnerReport.likesAmount ?? 0))
            }

         likeButton.view.startTapGestureRecognize(cancelTouch: true)

         likeButton.view.on(\.didTap, self) {
            let body = PressLikeRequest.Body(
               likeKind: 1,
               challengeReportId: winnerReport.id
            )
            let request = PressLikeRequest(
               token: "",
               body: body,
               index: index
            )
            $0.send(\.reactionPressed, request)

            likeButton.setState(.selected)
         }
         
         if winnerReport.userLiked == true {
            likeButton.setState(.selected)
         }
         
         let reactionsBlock = StackModel()
            .axis(.horizontal)
            .alignment(.leading)
            .distribution(.fill)
            .spacing(4)
            .arrangedModels([
               messageButton,
               likeButton,
               Grid.xxx.spacer
            ])
         
         let infoBlock = StackModel()
            .spacing(Grid.x10.value)
            .axis(.vertical)
            .alignment(.fill)
            .arrangedModels([
               awardedLabel,
               nicknameLabel,
               reactionsBlock
            ])
         
         let cellStack = WrappedX(
            StackModel()
               .padding(.outline(Grid.x8.value))
               .spacing(Grid.x12.value)
               .axis(.horizontal)
               .alignment(.center)
               .arrangedModels([
                  icon,
                  infoBlock,
                  Grid.x32.spacer,
                  receivedLabel.righted()
               ])
               .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
               .backColor(Design.color.background)
         )
         .padding(.verticalOffset(Grid.x6.value))
         .padding(.horizontalOffset(Design.params.commonSideOffset))
         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
         .shadow(Design.params.cellShadow)

         work.success(result: cellStack)
      }
   }
}

extension ChallWinnersPresenters: Eventable {
   struct Events: InitProtocol {
      var reactionPressed: PressLikeRequest?
   }
}
