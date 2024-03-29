//
//  WorkingPlaceBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja

// MARK: - WorkingPlaceBlock

final class WorkingPlaceBlock<Design: DSP>: ProfileStackModel<Design> {
   private lazy var title = LabelModel()
      .set(Design.state.label.medium16)
      .text(Design.text.workingPlace)

   private lazy var company = ProfileTitleBody<Design>
   { $0.title.text(Design.text.company) }
   private lazy var department = ProfileTitleBody<Design>
   { $0.title.text(Design.text.department) }
   private lazy var jobTitle = ProfileTitleBody<Design>
   { $0.title.text(Design.text.jobTitle) }

   override func start() {
      super.start()

      spacing(16)
      arrangedModels(
         title,
         company,
         department,
         jobTitle
      )
   }
}

extension WorkingPlaceBlock: StateMachine {
   func setState(_ state: UserWorkData) {
      company.setBody(state.company)
      department.setBody(state.department)
      jobTitle.setBody(state.jobTitle)

      hidden(false)
   }
}
