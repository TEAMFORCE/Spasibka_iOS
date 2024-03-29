//
//  ChallContendersPresenters.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.10.2022.
//

import StackNinja
import UIKit

class ChallContendersPresenters<Design: DesignProtocol>: Designable {
   var events: EventsStore = .init()
   
   var showButtons: Bool = false

   var contendersCellPresenter: CellPresenterWork<Contender, WrappedX<StackModel>> {
      CellPresenterWork { work in
         
         let index = work.unsafeInput.indexPath.row
         let contender = work.unsafeInput.item
         let createdAt = contender.reportCreatedAt
         let name = contender.participantName.unwrap
         let surname = contender.participantSurname.unwrap
         let reportText = contender.reportText.unwrap
         let reportId = contender.reportId

         let senderLabel = LabelModel()
            .text(name + " " + surname)
            .set(Design.state.label.descriptionRegular14)

         let createdAtLabel = LabelModel()
            .text(createdAt.dateFullConverted)
            .set(Design.state.label.regular12)
            .textColor(Design.color.textSecondary)

         let icon = ImageViewModel()
            .contentMode(.scaleAspectFill)
            .image(Design.icon.newAvatar)
            .size(.square(32))
            .cornerCurve(.continuous).cornerRadius(32 / 2)

         let infoBlock = HStackModel()
            .arrangedModels([
               senderLabel,
               Spacer(),
               createdAtLabel
            ])

         if let avatar = contender.participantPhoto {
            icon.url(SpasibkaEndpoints.urlBase + avatar)
         } else {
            let userIconText = String(name.first ?? "?") + String(surname.first ?? "?")
            DispatchQueue.global(qos: .background).async {
               let image = userIconText.drawImage(backColor: Design.color.backgroundBrand)
               DispatchQueue.main.async {
                  icon
                     .backColor(Design.color.backgroundBrand)
                     .image(image)
               }
            }
         }

         let userInfo = StackModel()
           // .padding(.outline(Grid.x8.value))
            .spacing(Grid.x12.value)
            .axis(.horizontal)
            .alignment(.center)
            .arrangedModels([
               icon,
               infoBlock
            ])
            .cornerCurve(.continuous)
            .cornerRadius(Design.params.cornerRadiusSmall)
            .backColor(Design.color.background)

         let photo = ImageViewModel()
            .image(Design.icon.transactSuccess)
            .height(214.aspected)
            .contentMode(.scaleAspectFill)
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            .hidden(true)

         if let photoLink = contender.reportPhoto, photoLink.count > 1 {
            let imageUrl = SpasibkaEndpoints.urlBase + photoLink
            photo.url(imageUrl)
            photo.view.on(\.didTap, self) {
               $0.send(\.presentImage, imageUrl)
            }
            photo.hidden(false)
         }

         let textLabel = LabelModel()
            .set(Design.state.label.descriptionRegular12)
            .numberOfLines(0)
            .text(reportText)

         let rejectButton = ButtonModel()
            .set(Design.state.button.default)
            .backColor(Design.color.backgroundBrand)
            .title(Design.text.reject)
            .font(Design.font.regular14)
            .padding(.horizontalOffset(Grid.x14.value))
            .height(Design.params.buttonHeightSmall)
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
         
         let acceptButton = ButtonModel()
            .set(Design.state.button.default)
            .title(Design.text.confirm)
            .font(Design.font.regular14)
            .padding(.horizontalOffset(Grid.x14.value))
            .height(Design.params.buttonHeightSmall)
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)

         rejectButton.view.on(\.didTap, self) {
            $0.send(\.rejectPressed, reportId)
         }

         acceptButton.view.on(\.didTap, self) {
            $0.send(\.acceptPressed, reportId)
         }

         let buttonsStack = StackModel()
            .padding(.outline(Grid.x8.value))
            .spacing(Grid.x12.value)
            .axis(.horizontal)
            .alignment(.center)
            .distribution(.fill)
            .arrangedModels([
               rejectButton,
               acceptButton
            ])
         
         if self.showButtons == false {
            buttonsStack.hidden(true)
            rejectButton.view.isUserInteractionEnabled = false
            acceptButton.view.isUserInteractionEnabled = false
         }
         
         let messageButton = ReactionButton<Design>()
            .setAll {
               $0.image(Design.icon.messageCloud)
               $1.text(String(contender.commentsAmount ?? 0))
            }

         let likeButton = ReactionButton<Design>()
            .setAll {
               $0.image(Design.icon.like)
               $1.text(String(contender.likesAmount ?? 0))
            }

         likeButton.view.startTapGestureRecognize(cancelTouch: true)

         likeButton.view.on(\.didTap, self) {
            let body = PressLikeRequest.Body(
               likeKind: 1,
               challengeReportId: contender.reportId
            )
            let request = PressLikeRequest(
               token: "",
               body: body,
               index: index
            )
            $0.send(\.reactionPressed, request)

            likeButton.setState(.selected)
         }
         
         if contender.userLiked == true {
            likeButton.setState(.selected)
         }
         
         let reactionsBlock = StackModel()
            .axis(.horizontal)
            .alignment(.leading)
            .distribution(.fill)
            .spacing(4)
            .arrangedModels([
               Spacer(),
               messageButton,
               likeButton
            ])

         let cellStack = WrappedX(
            StackModel()
               .padding(Design.params.cellContentPadding)
               .spacing(12)
               .alignment(.fill)
               .arrangedModels([
                  userInfo,
                  photo,
                  textLabel,
                  buttonsStack,
                  reactionsBlock
               ])
               .cornerCurve(.continuous)
               .cornerRadius(Design.params.cornerRadiusSmall)
               .backColor(Design.color.background)
         )
         .padding(.verticalOffset(6))
         .padHorizontal(Design.params.commonSideOffset)
         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
         .shadow(Design.params.cellShadow)

         work.success(result: cellStack)
      }
   }
}

extension ChallContendersPresenters: Eventable {
   struct Events: InitProtocol {
      var acceptPressed: Int?
      var rejectPressed: Int?
      var reactionPressed: PressLikeRequest?
      var presentImage: String?
   }
}
