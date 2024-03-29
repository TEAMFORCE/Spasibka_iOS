//
//  ActivityViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.09.2023.
//

import StackNinja

protocol ActivityViewModelProtocol: Designable {
   var activityBlock: ActivityViewModel<Design> { get }
}

extension ActivityViewModelProtocol {
   @discardableResult
   func activityState(_ state: ActivityViewModel<Design>.ModelState) -> Self {
      activityBlock.setState(state)
      return self
   }
}

extension ActivityViewModelProtocol where Self: Assetable, Asset.Design == Design {
   @discardableResult
   func activityState(_ state: ActivityViewModel<Design>.ModelState) -> Self {
      activityBlock.setState(state)
      return self
   }
}

final class ActivityViewModel<Design: DSP>: VStackModel {
   private lazy var activityIndicatorVM = Design.model.common.activityIndicator
   private lazy var hereIsEmptyVM = Design.model.common.hereIsEmpty
      .hidden(true)
   private lazy var firstCommentVM = Design.model.common.firstComment
      .hidden(true)
   private lazy var errorVM = Design.model.common.systemErrorBlock
      .hidden(true)
   
   override func start() {
      super.start()
      
      arrangedModels(activityIndicatorVM, hereIsEmptyVM, firstCommentVM, errorVM)
   }
}

extension ActivityViewModel: StateMachine {
   enum ModelState {
      case loading
      case empty
      case error
      case firstComment
      
      case hidden
   }
   
   func setState(_ state: ModelState) {
      switch state {
      case .loading:
         hidden(false)
         activityIndicatorVM.hidden(false)
         hereIsEmptyVM.hidden(true)
         firstCommentVM.hidden(true)
         errorVM.hidden(true)
      case .empty:
         hidden(false)
         activityIndicatorVM.hidden(true)
         hereIsEmptyVM.hidden(false)
         firstCommentVM.hidden(true)
         errorVM.hidden(true)
      case .error:
         hidden(false)
         activityIndicatorVM.hidden(true)
         hereIsEmptyVM.hidden(true)
         firstCommentVM.hidden(true)
         errorVM.hidden(false)
      case .firstComment:
         hidden(false)
         activityIndicatorVM.hidden(true)
         hereIsEmptyVM.hidden(true)
         firstCommentVM.hidden(false)
         errorVM.hidden(true)
      case .hidden:
         hidden(true)
      }
   }
}
