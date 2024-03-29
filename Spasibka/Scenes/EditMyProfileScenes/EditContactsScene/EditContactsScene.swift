//
//  EditContactsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.12.2022.
//

import StackNinja

enum EditContactsInOut: InOutParams {
   typealias Input = UserContactData
   typealias Output = UserContactData
}

struct EditContactsSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = BrandTripleStackVM<Asset.Design>
   }

   typealias InOut = EditContactsInOut
}

final class EditContactsScene<Asset: ASP>: BaseParamsScene<EditContactsSceneParams<Asset>>, Scenarible {
   lazy var scenario = EditContactsScenario<Asset>(
      works: EditContactsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: .init(
         onInput: on(\.input),
         //
         didChangeName: contactsVM.nameField.mainModel.on(\.didEditingChanged),
         didChangeSurName: contactsVM.surnameField.mainModel.on(\.didEditingChanged),
         didChangeMiddleName: contactsVM.middleField.mainModel.on(\.didEditingChanged),
         didSelecectGenderIndex: contactsVM.genderPicker.on(\.didSelectRow),
         didChangeEmail: contactsVM.emailField.mainModel.on(\.didEditingChanged),
         didChangePhone: contactsVM.phoneField.mainModel.on(\.didEditingChanged),
         didChangeBirthDate: contactsVM.datePicker.on(\.didDatePicked),
         //
         didTapBirthDateField: contactsVM.birthdateField.view.on(\.didTap),
         didTapHideYearLabel: contactsVM.hideYearLabel.on(\.didSelected),
         didTapGenderField: contactsVM.genderField.view.on(\.didTap),
         //
         didTapSaveButton: saveButton.on(\.didTap)
      )
   )

   private lazy var vkButton = VKLoginButton<Design>()
      .title(Design.text.connectVK)
      .on(\.didTap) {
         Asset.router?.route(.push, scene: \.loginVK, payload: .connectToCurrentAccount)
      }

   private lazy var contactsVM = EditContactsVM<Design>()

   private lazy var saveButton = ButtonSelfModable()
      .onModeChanged(\.normal) {
         $0.set(Design.state.button.default)
      }
      .onModeChanged(\.inactive) {
         $0.set(Design.state.button.inactive)
      }
      .setMode(\.inactive)
      .title(Design.text.save)

   override func start() {
      mainVM
         .backColor(Design.color.background)
      mainVM.bodyStack
         .spacing(16)
         .arrangedModels(
            vkButton,
            contactsVM
         )
      mainVM.footerStack
         .arrangedModels(
            saveButton
         )
      vcModel?.title(Design.text.contactDetails)

      scenario.configureAndStart()
   }
}

enum EditContactsSceneState {
   case setFields(UserContactData)
   //
   case setSaveEnabled
   case setSaveDisabled
   //
   case scrollToEndAndPresentPicker
   case presentBirthdatePicker
   case fieldState(EditContactsFieldState)
   //
   case updateDate(String)
   case updateGender(Gender)
   //
   case returnEditedContactsAndDismiss(UserContactData)
}

extension EditContactsScene: StateMachine {
   func setState(_ state: EditContactsSceneState) {
      switch state {
      case let .setFields(contacts):
         contactsVM.setState(.setFields(contacts))
      case .setSaveDisabled:
         saveButton.setMode(\.inactive)
      case .setSaveEnabled:
         saveButton.setMode(\.normal)
      case let .fieldState(fieldState):
         contactsVM.setState(.fieldState(fieldState))
      case let .returnEditedContactsAndDismiss(data):
         finishSucces(data)
         Asset.router?.pop()
         //dismiss()
      case .scrollToEndAndPresentPicker:
         contactsVM.datePickWrapper.hidden(!contactsVM.datePickWrapper.view.isHidden)
         contactsVM.view.layoutIfNeeded()
         contactsVM.scrollToEnd(true)
      case let .updateDate(date):
         contactsVM.setState(.setBirthDate(date))
      case .presentBirthdatePicker:
         contactsVM.genderPickerWrapper.hidden(!contactsVM.genderPickerWrapper.view.isHidden)
         contactsVM.view.layoutIfNeeded()
      case let .updateGender(gender):
         contactsVM.genderField.mainModel.text(gender.textForGender)
      }
   }
}
