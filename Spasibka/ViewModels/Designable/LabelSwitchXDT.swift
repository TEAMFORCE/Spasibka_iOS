//
//  LabelSwitchXDT.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.08.2022.
//

import StackNinja

final class LabelSwitcherXDT<Design: DSP>: LabelSwitcherX {
   override func start() {
      super.start()
      
      models.right.padding(.right(4))

      padding(Design.params.contentVerticalPadding)
      label
         .set(Design.state.label.medium16)
         .backColor(Design.color.background)
   }
}

final class SwitcherBox<Down: VMPS, Design: DSP>:
   Stack<LabelSwitcherXDT<Design>>.D<Down>.Ninja, Designable, Eventable
{
   typealias Events = SwitchEvent
   var events: EventsStore = .init()
   //
   var labelSwitcher: LabelSwitcherXDT<Design> { models.main }
   var optionModel: Down { models.down }

   override func start() {
      super.start()

      optionModel.hidden(true)
      labelSwitcher.switcher
         .on(\.turnedOn, self) {
            $0.optionModel.hidden(false)
            $0.send(\.turnedOn)
         }
         .on(\.turnedOff, self) {
            $0.optionModel.hidden(true)
            $0.send(\.turnedOff)
         }
   }
}
