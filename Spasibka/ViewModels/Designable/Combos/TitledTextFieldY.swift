//
//  TitledTextFieldY.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.09.2022.
//

import StackNinja

class TitledTextFieldY<Design: DesignProtocol>:
   Stack<LabelModel>.D<TextFieldModel>.Ninja,
   Designable,
   Eventable
{
   typealias Events = TextFieldEvents
   var events: EventsStore = .init()

   var title: LabelModel { models.main }
   var textField: TextFieldModel { models.down }

   required init() {
      super.init()

      setMain {
         $0
            .set(Design.state.label.bold24)
            .numberOfLines(0)
            .alignment(.center)
            .padTop(Grid.x8.value)
      } setDown: {
         $0
            .set(Design.state.label.regular16)
            .textColor(Design.color.textSecondary)
            .clearButtonMode(.never)
            .padding(.bottom(Grid.x8.value))
      }
      alignment(.center)

      textField.on(\.didEditingChanged) { [weak self] in
         self?.send(\.didEditingChanged, $0)
      }
   }
}
