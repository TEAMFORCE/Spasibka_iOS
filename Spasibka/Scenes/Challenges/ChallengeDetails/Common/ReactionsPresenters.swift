//
//  ReactionsPresenters.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 04.10.2022.
//

import StackNinja
import UIKit

class ReactionsPresenters<Design: DesignProtocol>: Designable {
   var events: EventsStore = .init()

   // TODO: - Add select users

   var reactionsCellPresenter: CellPresenterWork<[ReactItem], HStackModel> {
      CellPresenterWork { work in
         let items = work.unsafeInput.item

         var lineStackModels: [UIViewModel] = items.map { item in
            let user = item.user
            let icon = ImageViewModel()
               .contentMode(.scaleAspectFill)
               .image(Design.icon.newAvatar)
               .size(.square(Grid.x36.value))
               .cornerCurve(.continuous).cornerRadius(Grid.x36.value / 2)

            let senderLabel = LabelModel()
               .text((user.name.unwrap) + "\n" + (user.surname.unwrap))
               .set(Design.state.label.descriptionRegular12)

            if let avatar = user.avatar {
               icon.url(SpasibkaEndpoints.urlBase + avatar)
            } else {
               let userIconText =
                  String(user.name?.first ?? "?") +
                  String(user.surname?.first ?? "?")
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
                  .padding(Design.params.cellContentPadding)
                  .spacing(10)
                  .axis(.horizontal)
                  .alignment(.center)
                  .arrangedModels([
                     icon.wrappedX()
                        .addModel(
                           ImageViewModel()
                              .backColor(Design.color.transparent)
                              .image(Design.icon.redHeart, color: Design.color.iconError)
                              .size(.square(16)),
                           setup: {
                              $0.fitToBottomRight($1, offset: -2, sideOffset: -4)
                           }),
                     senderLabel
                  ])
                  .cornerCurve(.continuous)
                  .cornerRadius(Design.params.cornerRadiusSmall)
                  .backColor(Design.color.background)
                  .shadow(Design.params.cellShadow)
            )

            return cellStack
         }
         if lineStackModels.count % 2 != 0 {
            lineStackModels.append(Spacer())
         }

         let lineStack = HStackModel(lineStackModels)
            .spacing(16)
            .distribution(.fillEqually)
            .padBottom(10)
            .padHorizontal(16)

         work.success(lineStack)
      }
   }
}

extension ReactionsPresenters: Eventable {
   struct Events: InitProtocol {
      var didSelect: Int?
      var reactionPressed: PressLikeRequest?
   }
}
