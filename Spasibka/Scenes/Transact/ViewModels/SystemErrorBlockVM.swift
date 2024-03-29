//
//  TransactSendErrorViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 03.09.2022.
//

import StackNinja
import UIKit

struct SystemErrorBlockEvents: InitProtocol {
   var didClosed: Void?
}

final class SystemErrorBlockVM<Design: DSP>: BaseViewModel<StackViewExtended>,
   Eventable,
   Stateable2,
   Designable
{
   typealias State = StackState
   typealias State2 = ViewState

   typealias Events = SystemErrorBlockEvents

   var events = EventsStore()

   private(set) lazy var errorBlock = Design.model.common.connectionErrorBlock

   let button = Design.button.default
      .title(Design.text.closeButton)

   override func start() {
      set(Design.state.stack.default)
      backColor(Design.color.background)
      cornerRadius(Design.params.cornerRadius)
      cornerCurve(.continuous)
      alignment(.fill)

      arrangedModels([
         Grid.x24.spacer,
         errorBlock,
         Grid.x24.spacer,
         button
      ])

      button.on(\.didTap) { [weak self] in
         self?.send(\.didClosed)
      }
   }
}
