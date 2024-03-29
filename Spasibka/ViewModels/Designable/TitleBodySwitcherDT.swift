//
//  TitleBodySwitcherDT.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 22.08.2022.
//

import StackNinja

final class TitleBodySwitcherDT<Design: DSP>: TitleBodySwitcherY {
   override func start() {
      super.start()

      padding(Design.params.contentPadding)

      setAll { title, switcherStack in
         title
            .set(Design.state.label.regular12)
            .textColor(Design.color.textSecondary)
        
      }
   }
}
