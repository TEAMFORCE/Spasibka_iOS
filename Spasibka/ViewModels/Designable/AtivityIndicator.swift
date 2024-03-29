//
//  AtivityIndicator.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.09.2022.
//

import StackNinja
import UIKit

final class ActivityIndicator<Design: DSP>: BaseViewModel<UIActivityIndicatorView>, Stateable {
   typealias State = ViewState

   private var size: CGFloat = 1.33

   init(size: CGFloat = 1.33) {
      super.init()
      self.size = size
   }
   
   required init() {
      super.init()
   }
   
   override func start() {
      size(.square(100))
      view.startAnimating()
      view.color = Design.color.iconBrand
      view.contentScaleFactor = size
   }
}

final class ActivityIndicatorSpacedBlock<Design: DSP>: Stack<ActivityIndicator<Design>>.D<Spacer>.Ninja, Designable {
   required init() {
      super.init()

      setAll { _, _ in }
   }
}
