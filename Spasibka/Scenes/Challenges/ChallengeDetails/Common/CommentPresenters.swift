//
//  CommentPresenters.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 28.09.2022.
//

import StackNinja
import UIKit

class CommentPresenters<Design: DesignProtocol>: Designable {
   var events: EventsStore = .init()

   var commentCellPresenter: CellPresenterWork<Comment, WrappedX<StackModel>> {
      CellPresenterWork { work in
         let comment = work.unsafeInput.item

         let index = work.unsafeInput.indexPath.row
         let text = comment.text
         let created = comment.created?.timeAgoConverted
         let user = comment.user

         let senderLabel = LabelModel()
            .text((user?.name.unwrap ?? "") + " " + (user?.surname.unwrap ?? ""))
            .set(Design.state.label.labelRegular14)
            .userInterractionEnabled(true)

         let textLabel = LabelModel()
            .set(Design.state.label.descriptionRegular12)
            .text(text.unwrap)
            .numberOfLines(0)
            .userInterractionEnabled(true)

         let dateLabel = LabelModel()
            .text(created.unwrap)
            .set(Design.state.label.descriptionSecondary12)
            .numberOfLines(0)
         
         let editedLabel = LabelModel()
            .text(Design.text.edited)
            .set(Design.state.label.descriptionSecondary12)
            .numberOfLines(1)
            .hidden(true)

         let likeAmount = "0"

         let likeButton = ReactionButton<Design>()
            .setAll {
               $0.image(Design.icon.heart)
               $1.text(likeAmount)
            }
         
         likeButton.view.startTapGestureRecognize(cancelTouch: true)

         likeButton.view.on(\.didTap, self) {
            let body = PressLikeRequest.Body(
               likeKind: 1,
               commentId: comment.id
            )
            let request = PressLikeRequest(
               token: "",
               body: body,
               index: index
            )
            $0.send(\.reactionPressed, request)

            likeButton.setState(.selected)
         }
         
         if comment.userLiked == true {
            likeButton.setState(.selected)
         }
         if let likesAmount = comment.likesAmount {
            likeButton.models.right.text(String(likesAmount))
         }
         
         if let isEdited = comment.isEdited {
            editedLabel.hidden(!isEdited)
         }

         let senderAndDateBlock = StackModel()
            .axis(.horizontal)
            .alignment(.leading)
            .distribution(.fill)
            .spacing(4)
            .arrangedModels([
               senderLabel,
               Grid.xxx.spacer,
               dateLabel,
            ])
         let reactionsBlock = StackModel()
            .axis(.horizontal)
            .alignment(.leading)
            .distribution(.fill)
            .spacing(4)
            .arrangedModels([
               editedLabel,
               Grid.xxx.spacer,
               likeButton
            ])

         let infoBlock = StackModel()
            .spacing(Grid.x10.value)
            .axis(.vertical)
            .alignment(.fill)
            .arrangedModels([
               senderAndDateBlock,
               textLabel,
               reactionsBlock
            ])

         let icon = ImageViewModel()
            .contentMode(.scaleAspectFill)
            .image(Design.icon.newAvatar)
            .size(.square(Grid.x36.value))
            .cornerCurve(.continuous).cornerRadius(Grid.x36.value / 2)

         if let avatar = user?.avatar {
            icon.url(SpasibkaEndpoints.urlBase + avatar)
         } else {
            let userIconText =
            String(user?.name?.first ?? "?") +
            String(user?.surname?.first ?? "?")
            DispatchQueue.global(qos: .background).async {
               let image = userIconText.drawImage(backColor: Design.color.backgroundBrand)
               DispatchQueue.main.async {
                  icon
                     .backColor(Design.color.backgroundBrand)
                     .image(image)
               }
            }
         }

         let cellStack = WrappedX(
            StackModel()
               .spacing(Grid.x12.value)
               .axis(.horizontal)
               .alignment(.top)
               .arrangedModels([
                  icon,
                  infoBlock
               ])
               .padding(.outline(16))
         )
         .padding(.init(top: 12, left: 12, bottom: 12, right: 12))
         .backViewModel(
            ViewModel {
               $0
                  .backColor(Design.color.background)
                  .cornerCurve(.continuous)
                  .cornerRadius(Design.params.cornerRadiusSmall)
                  .shadow(Design.params.newCellShadow)
            }, inset: .init(top: 12, left: 16, bottom: 12, right: 16)
         )

         work.success(result: cellStack)
      }
   }
}

extension CommentPresenters: Eventable {
   struct Events: InitProtocol {
      var didSelect: Int?
      var reactionPressed: PressLikeRequest?
   }
}
