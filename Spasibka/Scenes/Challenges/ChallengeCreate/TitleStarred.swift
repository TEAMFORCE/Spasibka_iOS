//
//  TitleStarred.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.02.2024.
//

import StackNinja

final class TitleStarredVM<Design: DSP>: M<LabelModel>.R<LabelModel>.R2<Spacer>.Ninja {
   required init() {
      super.init()

      setAll { label, starLabel, _ in
         label
            .set(Design.state.label.labelRegular14)
            .textColor(Design.color.textSecondary)
         starLabel
            .set(Design.state.label.labelRegular14)
            .text("*")
            .textColor(Design.color.textError)
      }
   }

   @discardableResult
   func text(_ text: String) -> Self {
      models.main.text(text)

      return self
   }
}

final class TitleStarredInputModel<Design: DSP, WrappedModel: ViewModelProtocol>: VStackModel {
   let wrappedModel: WrappedModel

   private let starredTitle = TitleStarredVM<Design>()

   @discardableResult
   func warningStarHidden(_ isHidden: Bool) -> Self {
      starredTitle.models.right.hidden(isHidden)

      return self
   }

   required init(
      title: String,
      wrappedModel: WrappedModel
   ) {
      self.wrappedModel = wrappedModel
      super.init()

      starredTitle.models.main.text(title)
      starredTitle.models.right.hidden(true)
      spacing(8)
      arrangedModels(
         starredTitle,
         wrappedModel
      )
   }
   
   required init() {
      fatalError("init() has not been implemented")
   }
//
//   override func start() {
//      super.start()
//
//      arrangedModels(
//         starredTitle,
//         wrappedModel
//      )
//   }
}
