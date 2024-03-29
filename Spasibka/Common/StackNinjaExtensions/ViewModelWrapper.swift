//
//  ViewModelWrapper.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 15.09.2023.
//

import StackNinja

protocol ViewModelWrapperProtocol {
   associatedtype ViewModel: ViewModelProtocol
   var viewModel: ViewModel { get }
}

extension ViewModelWrapperProtocol {
   @discardableResult
   func setupViewModel(_ closure: (ViewModel) -> Void) -> Self {
      closure(viewModel)
      return self
   }
}

class BaseViewModelWrapper<
   ViewModel: ViewModelProtocol
>:
   BaseModel, ViewModelWrapperProtocol {
   
   private(set) lazy var viewModel: ViewModel = .init()
   
   init(setupViewModel: ((ViewModel) -> Void)? = nil) {
      super.init()
      setupViewModel?(self.viewModel)
   }
   
   required init() {
      super.init()
   }
}
