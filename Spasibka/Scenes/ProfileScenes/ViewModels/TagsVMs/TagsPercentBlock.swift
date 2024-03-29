//
//  TagsPercentBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja
import UIKit

// MARK: - TagsPercentBlock

final class TagsPercentBlock<Design: DSP>: ProfileStackModel<Design> {

   private var isCircularTextsEnabled = true
   //
   private lazy var diagram = DiagramVM()
      .size(.square(132))
      .addModel(sumLabel) { anchors, superview in
         anchors
            .centerX(superview.centerXAnchor)
            .centerY(superview.centerYAnchor)
      }

   private lazy var sumLabel = LabelModel()
      .set(Design.state.label.regular40)

   private lazy var tagsCloud = TagsPercentCloud<Design>()

   override func start() {
      super.start()

      spacing(16)
      arrangedModels(
         diagram.centeredX(),
         tagsCloud
      )
   }
}

extension TagsPercentBlock: StateMachine {
   func setState(_ state: [UserStat]) {
      let circleColors = UIColor("CE7BB0").colorsCircle(state.count)
      let graphs = state.enumerated().map {
         let percent = self.percentToInt($1.percentFromTotalAmount)
         return GraphData(
            percent: CGFloat($1.percentFromTotalAmount / 100),
            text: isCircularTextsEnabled ? "\(percent)" : "",
            color: circleColors[$0]
         )
      }

      let tags = state.enumerated().map {
         let percent = self.percentToInt($1.percentFromTotalAmount)
         return TagPercentCloudData(
            text: "\($1.name) \(percent)%",
            color: circleColors[$0]
         )
      }

      diagram.setState(graphs)
      tagsCloud.setState(tags)
      sumLabel.text("%")
//      sumLabel.text(state.reduce(Int(0)) { partialResult, stat in
//         partialResult + Int(stat.sum)
//      }.toString)

      hidden(false)
   }

   private func percentToInt(_ percent: Float) -> Int {
      Int(percent.rounded(.toNearestOrAwayFromZero))
   }

   @discardableResult
   func hideCircularTexts() -> Self {
      isCircularTextsEnabled = false
      return self
   }
}
