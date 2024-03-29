//
//  HashTagsScrollModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 03.10.2022.
//

import StackNinja

final class HashTagsScrollModel<Design: DSP>: ScrollStackedModelX, Designable {
   override func start() {
      super.start()
      
      set(.spacing(4))
      set(.hideHorizontalScrollIndicator)

      // TODO: - Временно
      userInterractionEnabled(true)
   }
}

extension HashTagsScrollModel: SetupProtocol {
   func setup(_ data: [FeedTag]?) {
      let tags = (data ?? []).map { tag in
         WrappedX(
            LabelModel()
               .set(Design.state.label.labelRegular10)
               .text("# " + tag.name)
               .textColor(Design.color.textInfo)
         )
//         .backColor(Design.color.infoSecondary)
//         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusMini)
//         .padding(.outline(8))
      }

      set(.arrangedModels(tags))
   }
}
