//
//  CheckMarkLabel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.01.2023.
//

import StackNinja
import CoreGraphics

struct CheckMarkLabelInput {
   let text: String
   let isSelected: Bool
   let leftOffset: CGFloat
}

final class CheckMarkLabel<Design: DSP>: Stack<CheckMarkModel<Design>>.R<LabelModel>.Ninja, Designable, Eventable {
   typealias Events = SelectableButtonEvents

   var checkMark: CheckMarkModel<Design> { models.main }
   var label: LabelModel { models.right }
   
   var events: EventsStore = .init()

   required init() {
      super.init()

      setAll { _, label in
         label
            .set(Design.state.label.descriptionRegular14)
      }
      spacing(10)
   }

   override func start() {
      super.start()

      models.right
         .makeTappable()
         .on(\.didTap, self) {
            $0.models.main.didTap()
         }

      models.main.on(\.didSelected, self) {
         $0.send(\.didSelected, $1)
      }
   }
}

enum CheckMarkLabelState {
   case text(String)
   case selected(Bool)
}

extension CheckMarkLabel: StateMachine {
   func setState(_ state: CheckMarkLabelState) {
      switch state {
      case let .text(value):
         models.right.text(value)
      case let .selected(value):
         models.main.setState(value)
      }
   }
}
