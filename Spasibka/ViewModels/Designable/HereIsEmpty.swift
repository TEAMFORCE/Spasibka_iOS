//
//  HereIsEmpty.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.10.2022.
//

import StackNinja

final class HereIsEmpty<Design: DSP>: LabelModel, Designable {
   override func start() {
      super.start()

      alignment(.center)
      set(Design.state.label.semibold14secondary)
      padding(.init(top: 24, left: 24, bottom: 24, right: 24))
      text(Design.text.hereIsEmpty)
   }
}

final class FirstComment<Design: DSP>: LabelModel, Designable {
   override func start() {
      super.start()

      alignment(.center)
      set(Design.state.label.descriptionRegular12)
      padding(.init(top: 24, left: 24, bottom: 24, right: 24))
      text(Design.text.firstComment)
      numberOfLines(0)
   }
}

final class HereIsEmptySpacedBlock<Design: DSP>: Stack<HereIsEmpty<Design>>.D<Spacer>.Ninja, Designable {
   required init() {
      super.init()

      setAll { _, _ in }
   }
}

