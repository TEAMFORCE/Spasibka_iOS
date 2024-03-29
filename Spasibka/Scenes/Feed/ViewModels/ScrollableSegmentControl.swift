//
//  ScrollableSegmentControl.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.07.2023.
//

import StackNinja

final class ScrollableSegmentControl<Design: DSP>: ScrollStackedModelX, Designable, Eventable2 {
   struct Events2: InitProtocol {
      var didTapButtonIndex: Int?
   }

   var events2 = EventsStore()

   private var buttons = [any ModableButtonModelProtocol]()

   override func start() {
      super.start()

      padding(.init(top: 0, left: 16, bottom: 8, right: 16))
      spacing(8)
      hideHorizontalScrollIndicator()
   }
   
   public func getButtonsCount() -> Int {
      buttons.count
   }
}

extension ScrollableSegmentControl: StateMachine {
   enum ModelState {
      case buttons([any ModableButtonModelProtocol])
      case updateButtonStates([Bool])
      case selectOneCategory(Int)
      case unselectAllButtons
   }

   func setState(_ state: ModelState) {
      switch state {
      case .buttons(let buttons):
         self.buttons = buttons
         arrangedModels(buttons)
         buttons.enumerated().forEach { index, button in
            button.on(\.didTap, self) { //[button] in
               $0.send(\.didTapButtonIndex, index)
               button.setMode(\.selected)
            }
         }
      case .updateButtonStates(let states):
         buttons.enumerated().forEach { index, button in
            button.setMode(states[index] ? \.selected : \.normal)
         }
      case .selectOneCategory(let id):
         for (index, button) in buttons.enumerated() {
            if index == id {
               button.setMode(\.selected)
            } else {
               button.setMode(\.normal)
            }
         }
      case .unselectAllButtons:
         for button in buttons {
            button.setMode(\.normal)
         }
      }
   }
}
