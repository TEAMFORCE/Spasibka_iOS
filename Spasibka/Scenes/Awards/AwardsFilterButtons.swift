//
//  AwardsFilterButtons.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.12.2023.
//

import StackNinja

enum AwardType {
   case transaction
   case challenge
   case unique
}

extension AwardsFilterButtons: Eventable {
   struct Events: InitProtocol {
      var didTapFilterAll: Void?
      var didTapFilterWithIndex: Int?
   }
}

final class AwardsFilterButtons<Design: DSP>: StackModel, Designable {
   var events: EventsStore = .init()

   private lazy var filterButtons = SlidingButtons(buttons: [filterAllButton])
   private lazy var filterAllButton = SecondaryButtonDT<Design>()
      .title(Design.text.all1)
      .font(Design.font.regular14)

   override func start() {
      super.start()

      arrangedModels([
         filterButtons,
      ])

      filterButtons.selectButtonAt(0)
      filterButtons.on(\.didTapButtonAtIndex, self) {
         if $1 == 0 {
            $0.send(\.didTapFilterAll)
         } else {
            $0.send(\.didTapFilterWithIndex, $1 - 1)
         }
      }
   }

   func setFilterButtons(_ buttons: [String]) {
      filterButtons.setButtons([filterAllButton] + buttons.map {
         SecondaryButtonDT<Design>()
            .title($0)
            .font(Design.font.regular14)
      })
   }
}
