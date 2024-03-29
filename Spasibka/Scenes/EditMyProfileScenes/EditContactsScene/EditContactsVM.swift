//
//  EditContactsVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.12.2022.
//

import StackNinja

final class EditContactsVM<Design: DSP>: ScrollStackedModelY {
   lazy var surnameField = makeEditField(badgeText: Design.text.surnameField)
   lazy var nameField = makeEditField(badgeText: Design.text.nameField)
   lazy var middleField = makeEditField(badgeText: Design.text.middleField)
   lazy var genderField = makeEditField(badgeText: Design.text.gender)
   lazy var emailField = makeEditField(badgeText: Design.text.emailField)
   lazy var phoneField = makeEditField(badgeText: Design.text.phoneField)
   lazy var birthdateField = makeEditField(badgeText: Design.text.birthdateField)
   lazy var hideYearLabel = CheckMarkLabel<Design>().setStates(.text(Design.text.hideYearOfBirth))

   lazy var datePicker = DatePickerModel()
      .datePickerMode(.date)

   lazy var datePickWrapper = WrappedX(datePicker)
      .borderWidth(1)
      .borderColor(Design.color.iconSecondary)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
      .hidden(true)

   lazy var genderPicker = EasyPickerModel()
      .height(133)
      .borderWidth(1)
      .borderColor(Design.color.iconSecondary)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
      .textColor(Design.color.text)

   lazy var genderPickerWrapper = Wrapped2Y(Spacer(12), genderPicker)
      .hidden(true)

   override func start() {
      super.start()

      phoneField.mainModel.keyboardType(.phonePad)

      birthdateField.mainModel.view.isEnabled = false
      birthdateField.view.startTapGestureRecognize()

      genderField.mainModel.view.isEnabled = false
      genderField.view.startTapGestureRecognize()

      arrangedModels(
         surnameField,
         nameField,
         middleField,
         genderField,
         genderPickerWrapper,
         emailField,
         phoneField,
         birthdateField,
         hideYearLabel,
         Spacer(12),
         datePickWrapper,
         Spacer(48)
      )
      spacing(4)
   }
}

enum EditContactsVMState {
   case setFields(UserContactData)
   case fieldState(EditContactsFieldState)
   case setBirthDate(String)
}

enum EditContactsFieldState {
   case surnameField(success: Bool)
   case nameField(success: Bool)
   case middleField(success: Bool)
   case emailField(success: Bool)
   case phoneField(success: Bool)
   case birthdateField(success: Bool)
}

extension EditContactsVM: StateMachine {
   func setState(_ state: EditContactsVMState) {
      switch state {
      case let .setFields(data):
         surnameField.mainModel.text(data.surname.string)
         nameField.mainModel.text(data.name.string)
         middleField.mainModel.text(data.middlename.string)
         emailField.mainModel.text(data.corporateEmail.string)
         phoneField.mainModel.text(data.mobilePhone.string)
         birthdateField.mainModel.text(data.dateOfBirth.string)
         if data.showBirthday == false {
            birthdateField.mainModel.text(data.dateOfBirth?.dateConverted(inputFormat: .dMMMy, outputFormat: .ddMM) ?? "")
         }
         hideYearLabel.setState(.selected(!(data.showBirthday ?? true)))

         datePickWrapper.hidden(true)
         genderPickerWrapper.hidden(true)

         let gender = data.gender ?? Gender.NotSelected
         genderField.mainModel.text(gender.textForGender)

         genderPicker.setState((options: Gender.allGenderTexts, selectedIndex: gender.index))

      case let .setBirthDate(dateStr):
         birthdateField.mainModel.text(dateStr)

      case let .fieldState(fieldState):
         switch fieldState {
         case let .surnameField(success: success):
            surnameField.set(.badgeLabelState(
               badgeState(success)
            ))
         case let .nameField(success: success):
            nameField.set(.badgeLabelState(
               badgeState(success)
            ))
         case let .middleField(success: success):
            middleField.set(.badgeLabelState(
               badgeState(success)
            ))
         case let .emailField(success: success):
            emailField.set(.badgeLabelState(
               badgeState(success)
            ))
         case let .phoneField(success: success):
            phoneField.set(.badgeLabelState(
               badgeState(success)
            ))
         case let .birthdateField(success: success):
            birthdateField.set(.badgeLabelState(
               badgeState(success)
            ))
         }
      }
   }

   private func badgeState(_ success: Bool) -> LabelState {
      success
         ? LabelState.textColor(Design.color.textSecondary)
         : LabelState.textColor(Design.color.textError)
   }
}

extension EditContactsVM {
   private func makeEditField(badgeText: String) -> TopBadger<TextFieldModel> {
      TopBadger<TextFieldModel>()
         .set(.badgeLabelStates(Design.state.label.regular12Secondary))
         .set(.badgeState(.backColor(Design.color.background)))
         .set(.presentBadge(badgeText))
         .set {
            $0.mainModel
               .set(Design.state.textField.default)
               .disableAutocorrection()
               .placeholder(badgeText)
               .placeholderColor(Design.color.textFieldPlaceholder)
         }
   }
}
