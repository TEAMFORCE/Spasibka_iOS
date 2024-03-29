//
//  CreateChallengePanel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.11.2022.
//

import StackNinja

final class ChallengesFilterButtons<Design: DSP>: StackModel, Designable {
   var events: EventsStore = .init()

   private(set) lazy var filterButtons = SlidingManyButtons<Button3Event>(
      buttons:

      SecondaryButtonDT<Design>()
         .title(Design.text.activeChallenges)
         .font(Design.font.regular14),
      SecondaryButtonDT<Design>()
         .title(Design.text.deferredChallenges)
         .font(Design.font.regular14),
      SecondaryButtonDT<Design>()
         .title(Design.text.completedChains)
         .font(Design.font.regular14)
   )

   override func start() {
      super.start()

      arrangedModels([
         filterButtons
      ])

      filterButtons.on(\.didTapButtons, self) {
         switch $1 {
         case .didTapButton1:
            $0.send(\.didTapFilterActive)
         case .didTapButton2:
            $0.send(\.didTapFilterDeferred)
         case .didTapButton3:
            $0.send(\.didTapCompletedChains)
         }
      }
      filterButtons.setSelectedButton(1)
   }
}

extension ChallengesFilterButtons: Eventable {
   struct Events: InitProtocol {
      var didTapCompletedChains: Void?
      var didTapFilterActive: Void?
      var didTapFilterDeferred: Void?
   }
}
