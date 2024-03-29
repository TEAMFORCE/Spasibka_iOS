//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja

// MARK: - UserNameBlock

struct UserNameBlockData {
   let text1: String
   let text2: String
   let text3: String
}

final class UserNameBlock<Design: DSP>: Stack<LabelModel>.R<LabelModel>.R2<LabelModel>.R3<Spacer>.Ninja,
                                        Designable
{
   required init() {
      super.init()

      setAll { name, surname, nickname, _ in
         name
            .set(Design.state.label.bold32)
         surname
            .set(Design.state.label.bold32)
            .textColor(Design.color.textBrand)
         nickname
            .set(Design.state.label.bold32)
      }
   }
}

extension UserNameBlock: StateMachine {
   func setState(_ state: UserNameBlockData) {
      models.main.text(state.text1)
      models.right.text(state.text2)
      models.right2.text(state.text3)
   }
}
