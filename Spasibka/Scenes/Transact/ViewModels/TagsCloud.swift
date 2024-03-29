//
//  TagsCloud.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.02.2023.
//

import StackNinja
import UIKit

struct TagsCloudEvent: InitProtocol {
   var updateTags: Set<Tag>?
}

final class TagsCloud<Design: DSP>: StackModel, Designable, Eventable {
   typealias Events = TagsCloudEvent
   var events: EventsStore = .init()
   
   //private var tags: [SelectWrapper<Tag>] = []
   
   override func start() {
      spacing(8)
      alignment(.leading)
   }
   
   private func tagBuild(icon _: UIImage, name _: String, isSelected _: Bool) -> TagCloudButton<Design> {
      let button = TagCloudButton<Design>()
         .setAll { _, _ in }
      return button
   }
}

extension TagsCloud: StateMachine {

   private func tagIconForIndex(_ index: Int) -> UIImage {
      [
         Design.icon.tablerUsers,
         Design.icon.tablerBrandRedhat,
         Design.icon.tablerRobot,
         Design.icon.uilShieldSlash,
         Design.icon.tablerRocket,
         Design.icon.tablerChess,
         Design.icon.like
      ][safe: index] ?? Design.icon.tablerDiamond
   }

   func setState(_ state: [SelectWrapper<Tag>]) {
     // tags = state
      
      var currStack = StackModel()
         .axis(.horizontal)
         .spacing(8)
      var tagButts: [UIViewModel] = []
      let width = view.frame.width / 1.5
      var currWidth: CGFloat = 0
      let spacing: CGFloat = 8
      
      state.enumerated().forEach { ind, tag in
         let button = TagCloudButton<Design>()
            .setAll { icon, title in
               icon.image(tagIconForIndex(ind))
               title.text(tag.value.name.unwrap)
            }
         
         button.view.startTapGestureRecognize()
         button.view.on(\.didTap, self) { [button] in
            let tag = state[ind]
            let isSelected = tag.isSelected
            state[ind].isSelected = !isSelected
            
            if !isSelected {
               button.setState(.selected)
            } else {
               button.setState(.none)
            }
            
            $0.send(
               \.updateTags,
                Set(state
                  .filter(\.isSelected)
                  .map(\.value)
                )
            )
         }
         currStack.addArrangedModels([button])
         self.view.layoutIfNeeded()
         let butWidth = button.uiView.frame.width
         
         currWidth += butWidth + spacing
         
         let isNotFit = currWidth > width
         if isNotFit ||
               (ind == state.count - 1)
         {
            tagButts.append(currStack)
            currStack.removeLastModel()
            currStack = StackModel()
               .axis(.horizontal)
               .spacing(8)
            currStack.addArrangedModels([button])
            currWidth = 0
         }
      }
      
      arrangedModels(tagButts)
   }
}

final class TagCloudButton<Design: DSP>: Stack<ImageViewModel>.R<LabelModel>.Ninja, Designable {
   required init() {
      super.init()
      
      setAll {
         $0
            .size(.square(Grid.x16.value))
            .imageTintColor(Design.color.textContrastSecondary)
         $1
            .set(Design.state.label.regular12)
            .textColor(Design.color.textContrastSecondary)
      }
      spacing(4)
      backColor(Design.color.infoSecondary)
      cornerRadius(Design.params.cornerRadiusSmall)
      cornerCurve(.continuous)
      height(32)
      padding(.horizontalOffset(8))
      //borderColor(Design.color.iconBrand)
//      borderWidth(1)
   }
}

extension TagCloudButton: StateMachine {
   func setState(_ state: SelectState) {
      switch state {
      case .none:
         backColor(Design.color.infoSecondary)
         models.right.textColor(Design.color.textContrastSecondary)
         models.main.imageTintColor(Design.color.textContrastSecondary)
      case .selected:
         backColor(Design.color.backgroundBrandSecondary)
         models.right.textColor(Design.color.textBrand)
         models.main.imageTintColor(Design.color.iconBrand)
      case .loading:
         break
      }
   }
}
