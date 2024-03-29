//
//  UserLastRateBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.12.2022.
//

import StackNinja

// MARK: - UserSettingsBlock

final class UserLastRateBlock<Design: DSP>: ProfileStackModel<Design> {
   private lazy var title = LabelModel()
      .set(Design.state.label.medium16)
      .numberOfLines(2)
      .text(Design.text.engagementIndexForCurrentPeriod)

   private lazy var lastRate = ProfileTitleBody<Design>
   { $0.title.text(Design.text.engagementIndex) }

   override func start() {
      super.start()

      spacing(16)
      arrangedModels(
         title,
         lastRate
      )
   }
}

extension UserLastRateBlock: StateMachine {
   func setState(_ state: LastPeriodRate) {
      lastRate.setBody(String(state.rate) + "%")

      hidden(false)
   }
}
