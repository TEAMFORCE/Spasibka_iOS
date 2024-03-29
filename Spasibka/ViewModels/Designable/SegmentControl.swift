//
//  SegmentControl.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.09.2023.
//

import StackNinja

final class SegmentControl<ButtEvents: ManyButtonEvent>: HStackModel, IndexedButtonsProtocol
{
   typealias Events = ManyButtonsTapEvent<ButtEvents>

   var events: EventsStore = .init()
   var buttons: [any ModableButtonModelProtocol] = []

   init(buttons: any ModableButtonModelProtocol...) {
      super.init()

      guard buttons.isEmpty == false else { return }
      self.buttons = buttons
      configure()
   }

   private func configure() {
      buttons.first?.setMode(\.selected)
      buttons.enumerated().forEach { tuple in
         tuple.element
            .on(\.didTap, self) { slf in
               guard let event = ButtEvents(rawValue: tuple.offset) else { return }

               slf.setButtonTapped(event)
            }
      }

      distribution(.fillProportionally)
      alignment(.center)
      arrangedModels(buttons)
   }

   func setSelectedButton(_ index: Int) {
      if buttons.indices.contains(index) {
         buttons.forEach { but in but.setMode(\.normal) }
         buttons[index].setMode(\.selected)
      }
   }

   func setButtonTapped(_ event: ButtEvents) {
      buttons.forEach { but in but.setMode(\.normal) }

      let index = event.rawValue
      buttons[index].setMode(\.selected)

      send(\.didTapButtons, event)
   }

   required init() {
      fatalError("init() has not been implemented")
   }
}
