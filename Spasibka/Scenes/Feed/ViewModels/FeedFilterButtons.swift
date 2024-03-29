//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.08.2022.
//

import Foundation
import StackNinja

// final class FeedFilterButtons<Design: DSP>: StackModel, Designable, Eventable {
//   struct Events: InitProtocol {
//      var didTapAll: Void?
//      var didTapMy: Void?
//      var didTapPublic: Void?
//   }
//
//   var events = [Int: LambdaProtocol?]()
//
//   lazy var buttonAll = SecondaryButtonDT<Design>()
//      .title("Все")
//      .on(\.didTap) { [weak self] in
//         self?.select(0)
//         self?.send(\.didTapAll)
//      }
//
//   lazy var buttonMy = SecondaryButtonDT<Design>()
//      .title("Мои")
//      .on(\.didTap) { [weak self] in
//         self?.select(1)
//         self?.send(\.didTapMy)
//      }
//
//   lazy var buttonPublic = SecondaryButtonDT<Design>()
//      .title("Публичные")
//      .on(\.didTap) { [weak self] in
//         self?.select(2)
//         self?.send(\.didTapPublic)
//      }
//
//   lazy var buttonCalendar = SecondaryButtonDT<Design>()
//      .image(Design.icon.calendar)
//      .width(52)
//      .backColor(Design.color.backgroundBrandSecondary)
//      .on(\.didTap) { [weak self] in
//         self?.select(3)
//      }
//
//   override func start() {
//      axis(.horizontal)
//      spacing(Grid.x8.value)
//      padBottom(8)
//      arrangedModels([
//         buttonAll,
//         buttonMy,
//         buttonPublic,
//         Grid.xxx.spacer,
//      //   buttonCalendar
//      ])
//   }
//
//   private func deselectAll() {
//      buttonAll.setMode(\.normal)
//      buttonMy.setMode(\.normal)
//      buttonPublic.setMode(\.normal)
//   }
//
//   private func select(_ index: Int) {
//      deselectAll()
//      switch index {
//      case 1:
//         buttonMy.setMode(\.selected)
//      case 2:
//         buttonPublic.setMode(\.selected)
//      case 3:
//         buttonCalendar.setMode(\.selected)
//      default:
//         buttonAll.setMode(\.selected)
//      }
//   }
// }

final class FeedDetailFilterButtons<Design: DSP>: StackModel, Designable, Eventable {
   struct Events: InitProtocol {
      var didTapDetails: Void?
      var didTapComments: Void?
      var didTapReactions: Void?
   }

   var events = EventsStore()

   lazy var buttonDetails = SecondaryButtonDT<Design>()
      .title(Design.text.details)
      .font(Design.font.labelRegular14)
      .on(\.didTap, self) {
         $0.select(0)
         $0.send(\.didTapDetails)
      }

   lazy var buttonComments = SecondaryButtonDT<Design>()
      .title(Design.text.comments)
      .font(Design.font.labelRegular14)
      .on(\.didTap, self) {
         $0.select(1)
         $0.send(\.didTapComments)
      }

   lazy var buttonReactions = SecondaryButtonDT<Design>()
      .title(Design.text.reactions)
      .font(Design.font.labelRegular14)
      .on(\.didTap, self) {
         $0.select(2)
         $0.send(\.didTapReactions)
      }

   override func start() {
      axis(.horizontal)
      spacing(Grid.x8.value)
      padBottom(8)
      arrangedModels([
         buttonDetails,
         buttonComments,
         buttonReactions,
         Grid.xxx.spacer,
      ])
   }

   private func deselectAll() {
      buttonDetails.setMode(\.normal)
      buttonComments.setMode(\.normal)
      buttonReactions.setMode(\.normal)
   }

   private func select(_ index: Int) {
      deselectAll()
      switch index {
      case 0:
         buttonDetails.setMode(\.selected)
      case 1:
         buttonComments.setMode(\.selected)
      default:
         buttonReactions.setMode(\.selected)
      }
   }
}

final class FeedReactionsFilterButtons<Design: DSP>: StackModel, Designable, Eventable {
   struct Events: InitProtocol {
      var didTapAll: Void?
      var didTapLikes: Void?
   }

   var events = EventsStore()

   lazy var buttonAll = SecondaryButtonDT<Design>()
      .title(Design.text.all1)
      .font(Design.font.labelRegular14)
      .on(\.didTap) { [weak self] in
         self?.select(0)
         self?.send(\.didTapAll)
      }

   lazy var buttonLikes = SecondaryButtonDT<Design>()
      .title(Design.text.like)
      .font(Design.font.labelRegular14)
      .on(\.didTap) { [weak self] in
         self?.select(1)
         self?.send(\.didTapLikes)
      }

//   lazy var buttonDislikes = SecondaryButtonDT<Design>()
//      .title("Дизлайк")
//      .font(Design.font.default)
//      .on(\.didTap) { [weak self] in
//         self?.select(2)
//         self?.send(\.didTapDislikes)
//      }

   override func start() {
      axis(.horizontal)
      spacing(Grid.x8.value)
      padBottom(8)
      arrangedModels([
         buttonAll,
         buttonLikes,
         //   buttonDislikes,
         Grid.xxx.spacer,
      ])
   }

   private func deselectAll() {
      buttonAll.setMode(\.normal)
      buttonLikes.setMode(\.normal)
//      buttonDislikes.setMode(\.normal)
   }

   private func select(_ index: Int) {
      deselectAll()
      switch index {
      case 1:
         buttonLikes.setMode(\.selected)
//      case 2:
//         buttonDislikes.setMode(\.selected)
      default:
         buttonAll.setMode(\.selected)
      }
   }
}
