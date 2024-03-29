//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.08.2022.
//

import StackNinja
import UIKit

// MARK: - View Models --------------------------------------------------------------

final class MainScreenVM<Design: DesignProtocol>: WrappedX<M<StackModel>.D<StackModel>.Ninja>, Designable {
   var mainModel: M<StackModel>.D<StackModel>.Ninja { subModel }

   var headerStack: StackModel { subModel.models.main }
   var bodyStack: StackModel { subModel.models.down }

   override func start() {
      super.start()

      bodyStack.clipsToBound(true)
      setState(.loading)
   }
}

enum TripleStacksState {
   case loading
   case presentErrorModel(UIViewModel)
   case ready
}

extension MainScreenVM: StateMachine {
   func setState(_ state: TripleStacksState) {
      switch state {
      case .loading:
         hideActivityModel()
         presentActivityModel(Design.model.common.activityIndicator)
      case let .presentErrorModel(model):
         hideActivityModel()
         presentActivityModel(model)
      case .ready:
         hideActivityModel()
         UIView.setAnimationsEnabled(false)
         mainModel.setAll { headerStack, bodyStack in
            headerStack
               .backColor(Design.color.backgroundBrand)
               .arrangedModels(
                  Spacer(topSafeAreaInset())
               )
            bodyStack
               .backColor(Design.color.background)
               .safeAreaOffsetDisabled()
         }
         view.layoutIfNeeded()
         UIView.setAnimationsEnabled(true)
      }
   }
}
