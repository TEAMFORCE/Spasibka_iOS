//
//  ProgressBarVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.09.2023.
//

import StackNinja
import UIKit

final class ProgressBarWithLabelVM<Design: DSP>: Stack<ProgressBarVM<Design>>.R<LabelModel>.Ninja {
   var bar: ProgressBarVM<Design> { models.main }
   var label: LabelModel { models.right }
   
   required init() {
      super.init()
      
      setAll { _, progressLabel in
         progressLabel
            .set(Design.state.label.descriptionMedium16)
            .textColor(Design.color.text)
      }
      .spacing(30)
     // .padHorizontal(24)
   }
}

final class ProgressBarVM<Design: DSP>: HStackModel {

   private let fullHeight: CGFloat = 34
   private let barHeight: CGFloat = 11

   private lazy var progressViewModel = ViewModel()
      .backColor(Design.color.backgroundBrand)
   private lazy var pointerViewModel = ImageViewModel()
      .image(Design.icon.rocket)
      .padding(.outline(4))
      .wrappedX()
      .backColor(Design.color.backgroundBrandSecondary)
      .cornerRadius(fullHeight/2)
      .size(.square(fullHeight))
      .shadow(Design.params.cellShadow)
   
   private var progressValue: CGFloat = 0

   override func start() {
      super.start()
      
      height(fullHeight)
      arrangedModels(
         ViewModel()
            .height(barHeight)
            .backColor(Design.color.backgroundBrand.withAlphaComponent(0.25))
            .addModel(progressViewModel)
            .cornerRadius((barHeight/2))
            .clipsToBound(true)
      )
      addModel(pointerViewModel)
      alignment(.center)
      view.on(\.didLayout, self) {
         let width = $0.view.frame.size.width * $0.progressValue
         guard width > 0 else { return }
         
         $0.progressViewModel.view.frame.size = .init(width: width, height: $0.barHeight)
         $0.progressViewModel.view.center.y = ($0.barHeight) / 2
         $0.pointerViewModel.view.center = .init(x: width, y: $0.fullHeight / 2)
      }
   }
   
   @discardableResult
   func progressValue(_ value: CGFloat) -> Self {
      progressValue = min(max(value, 0.0), 1.0)
      return self
   }
}
