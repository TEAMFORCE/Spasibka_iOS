//
//  VCModel+Loading.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.11.2022.
//

import StackNinja
import UIKit

enum DarkLoadingState {
   case loading(onView: UIView?)
   case hide
}

final class DarkLoaderVM<Design: DSP>: ViewModel, Designable {
   private lazy var darkView = ViewModel()
      .backColor(.black.withAlphaComponent(0.5))
      .addModel(Design.model.common.activityIndicator) { anchors, superview in
         anchors
            .centerX(superview.centerXAnchor)
            .centerY(superview.centerYAnchor)
      }

   override func start() {
      super.start()
   }
}

extension DarkLoaderVM: StateMachine {
   func setState(_ state: DarkLoadingState) {
      switch state {
      case .loading(let view):
         if let view {
            view.addSubview(darkView.uiView)
            darkView.uiView.addAnchors.fitToView(view)
         }
      case .hide:
         darkView.uiView.removeFromSuperview()
      }
   }
}
