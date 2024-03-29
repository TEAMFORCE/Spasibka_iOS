//
//  TemplateFilterButtons.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 23.05.2023.
//

import StackNinja

final class TemplatesFilterButtons<Design: DSP>: StackModel, Designable {
   var events: EventsStore = .init()

   private var isEnabled = true

   private lazy var filterButtons = SlidingManyButtons<Button3Event>(
      buttons:
      SecondaryButtonDT<Design>()
         .title(Design.text.my)
         .font(Design.font.regular14),
      SecondaryButtonDT<Design>()
         .title(Design.text.ours)
         .font(Design.font.regular14),
      SecondaryButtonDT<Design>()
         .title(Design.text.common)
         .font(Design.font.regular14)
   )
   //.height(16 + 38)
   .backColor(Design.color.background)

   override func start() {
      super.start()

      arrangedModels([
         filterButtons,
      ])

      filterButtons.on(\.didTapButtons, self) {
         guard $0.isEnabled else { return }

         switch $1 {
         case .didTapButton1:
            $0.send(\.didTapFilterMy)
         case .didTapButton2:
            $0.send(\.didTapFilterOurs)
         case .didTapButton3:
            $0.send(\.didTapFilterCommon)
         }

         $0.send(\.didSelectButton, $1)
      }
      filterButtons.setSelectedButton(0)
   }

   @discardableResult func enabled(_ value: Bool) -> Self {
      isEnabled = value
      filterButtons.buttons.forEach {
         $0.userInterractionEnabled(value)
      }
      return self
   }
}

extension TemplatesFilterButtons: Eventable {
   struct Events: InitProtocol {
      var didTapFilterMy: Void?
      var didTapFilterOurs: Void?
      var didTapFilterCommon: Void?

      var didSelectButton: Button3Event?
   }
}

extension TemplatesFilterButtons: StateMachine {
   func setState(_ scope: ChallengeTemplatesScope) {
      filterButtons.setSelectedButton(scope.rawValue)
   }
}
