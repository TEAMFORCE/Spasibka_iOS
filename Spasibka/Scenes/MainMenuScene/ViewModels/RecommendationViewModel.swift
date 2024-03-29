//
//  RecommendationViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 06.02.2024.
//

import StackNinja
import UIKit


final class RecommendationCell<Design: DSP>: Stack<VStackModel>.Ninja, ModableButtonModelProtocol {
   typealias State = StackState
   typealias State2 = ButtonState
   
   var events = EventsStore()
   var modes: ButtonMode = .init()
   
   private lazy var backImage = ImageViewModel()
      .backColor(Design.color.backgroundBrandSecondary)
      .contentMode(.scaleAspectFill)
      .cornerRadius(Design.params.cornerRadiusSmall)
      .cornerCurve(.continuous)
      .addModel(
         ViewModel()
            .cornerRadius(Design.params.cornerRadiusSmall)
            .cornerCurve(.continuous)
            .backColor(Design.color.constantBlack)
            .alpha(0.33)
      ) {
         $0.fitToView($1)
      }

   private lazy var titleModel = LabelModel()
      .set(Design.state.label.descriptionRegular10)
      .textColor(Design.color.textSecondary)
      .numberOfLines(1)

   private lazy var authorModel = LabelModel()
      .set(Design.state.label.descriptionRegular10)
      .textColor(Design.color.text)
      .numberOfLines(1)
      .padBottom(12)
  
   private lazy var newLabel = LabelModel()
      .text("New")
      .alignment(.center)
      .set(Design.state.label.descriptionMedium8)
      .textColor(Design.color.textInvert)
      .backColor(Design.color.iconBrand)
      .padding(.init(top: 4, left: 6, bottom: 4, right: 6))
      .cornerCurve(.continuous)
      .cornerRadius(8)
      .hidden(true)


   override func start() {
      super.start()

      let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

      addModel(
         Wrapped2Y(titleModel, authorModel)
            .padVertical(8)
            .padHorizontal(9)
            .backColor(Design.color.background)
            .cornerRadius(Design.params.cornerRadiusSmall)
            .cornerCurve(.continuous)
            .maskedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
      ) {
         $0.fitToBottom($1)
      }
      backViewModel(
         backImage.wrappedY(),
         inset: padding
      )
      addModel(newLabel) { anchors, superview in
         anchors
            .top(superview.topAnchor, -3)
            .right(superview.rightAnchor, 6)
      }
      
      height(170.aspected)
      width(139.aspected)
      shadow(Design.params.newCellShadow)
      setNeedsStoreModelInView()
      
      view.startTapGestureRecognize()
      view.on(\.didTap, self) {
         self.view.animateTap(uiView: self.view)
         $0.send(\.didTap)
      }
   }
}
enum RecommendationCellState {
   case title(String)
   case author(String)
   case imageUrl(String?)
   case isNew(Bool?)
}

extension RecommendationCell: StateMachine {
   func setState(_ state: RecommendationCellState) {
      switch state {
      case let .title(text):
         titleModel.text(text)
      case let .author(text):
         authorModel.text(text)
      case let .imageUrl(url):
         backImage.indirectUrl(url)
      case let .isNew(value):
         if let isNew = value, isNew == true {
            newLabel.hidden(false)
         }
      }
   }
}
