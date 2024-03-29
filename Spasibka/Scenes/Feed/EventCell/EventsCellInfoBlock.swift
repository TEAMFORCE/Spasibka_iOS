//
//  EventsCellInfoBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.07.2023.
//

import StackNinja

final class EventsCellInfoBlock<Design: DSP>:
    M<LabelLabelMR>
   //.D<LabelModel>
   .D<LinkTappingLabel>
   .D2<HashTagsScrollModel<Design>>
   .D3<ReactionButtonsHStack<Design>>
   .D4<StackModel>
   .Ninja
{
   var titleLabel: LabelModel { models.main.models.main }
   var dateLabel: LabelModel { models.main.models.right }
   var textLabel: LinkTappingLabel { models.down }
   var hashTagsScroll: HashTagsScrollModel<Design> { models.down2 }
   var reactionButtons: ReactionButtonsHStack<Design> { models.down3 }
   var birtdayStack: StackModel { models.down4 }
   
   var birtdayButton = ButtonModel()
      .font(Design.font.descriptionRegular12)
      .padding(.horizontalOffset(Grid.x12.value))
      .height(Design.params.buttonHeightSmall)
      .cornerRadius(Design.params.buttonHeightSmall / 2)
      .cornerCurve(.continuous)
      .shadow(Design.params.newCellShadow)
      .backColor(Design.color.backgroundBrand)
      .textColor(Design.color.textInvert)
      .title("Поздравить")
   
   required init() {
      super.init()

      setAll { label, text, tags, _, birtdayStack in
         label.setAll { header, date in
            header
               .set(Design.state.label.labelRegular14)
               .numberOfLines(1)
            date
               .set(Design.state.label.descriptionSecondary12)
               .numberOfLines(1)
         }
         
         text
            .backColor(Design.color.background)
            .set(Design.state.label.descriptionRegular12)
         tags
            .padding(.top(8))
            .passThroughTouches()
         birtdayStack
            .axis(.horizontal)
            .arrangedModels([
               Grid.xxx.spacer,
               birtdayButton
            ])
            .hidden(true)
         
      }
      spacing(8)
   }
}

class LabelLabelMR: StackNinja<SComboMR<LabelModel, LabelModel>> {}
