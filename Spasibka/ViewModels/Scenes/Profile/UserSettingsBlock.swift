//
//  UserSettingsBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja

// MARK: - UserSettingsBlock

final class UserSettingsBlock<Design: DSP>: ProfileStackModel<Design> {
   var events: EventsStore = .init()

   override func start() {
      super.start()

      axis(.horizontal)
      alignment(.center)
      arrangedModels(
         LabelModel()
            .set(Design.state.label.medium16)
            .text(Design.text.settings),
         Spacer(),
         ImageViewModel()
            .size(.square(24))
            .image(Design.icon.tablerSettings, color: Design.color.iconContrast)
      )

      view.startTapGestureRecognize()
      view.on(\.didTap, self) { $0.send(\.didTap) }
   }
}

extension UserSettingsBlock: Eventable {
   typealias Events = TappableEvent
}

