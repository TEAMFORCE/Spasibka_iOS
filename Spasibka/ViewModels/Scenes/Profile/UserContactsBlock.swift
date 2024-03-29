//
//  UserContactsBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja

// MARK: - UserContactsBlock

final class UserContactsBlock<Design: DSP>: ProfileStackModel<Design> {
   private lazy var title = LabelModel()
      .set(Design.state.label.medium16)
      .text(Design.text.contactDetails)

   private lazy var surname = ProfileTitleBody<Design>
   { $0.title.text(Design.text.surnameField) }
   private lazy var name = ProfileTitleBody<Design>
   { $0.title.text(Design.text.nameField) }
   private lazy var middlename = ProfileTitleBody<Design>
   { $0.title.text(Design.text.middleField) }
   private lazy var gender = ProfileTitleBody<Design>
   { $0.title.text(Design.text.gender) }
   private lazy var email = ProfileTitleBody2<Design>
   { $0.title.text(Design.text.emailField) }
   private lazy var phone = ProfileTitleBody2<Design>
   { $0.title.text(Design.text.phoneField) }
   private lazy var birthDate = ProfileTitleBody<Design>
   { $0.title.text(Design.text.birthdateField) }

   override func start() {
      super.start()

      spacing(16)
      arrangedModels(
         title,
         surname,
         name,
         middlename,
         gender,
         email,
         phone,
         birthDate
      )
   }
}

extension UserContactsBlock: StateMachine {
   func setState(_ state: UserContactData) {
      surname.setBody(state.surname)
      name.setBody(state.name)
      middlename.setBody(state.middlename)
      email.setBody(state.corporateEmail)
      phone.setBody(state.mobilePhone)
      birthDate.setBody(state.dateOfBirth)
      
      setGender(state.gender)

      hidden(false)
   }
   
   private func setGender(_ value: Gender?) {
      switch value {
      case .W:
         gender.setBody(Design.text.woman)
      case .M:
         gender.setBody(Design.text.man)
      case .NotSelected:
         gender.setBody(Design.text.notIndicated)
      case .none:
         gender.setBody(Design.text.notIndicated)
      }
   }
}
