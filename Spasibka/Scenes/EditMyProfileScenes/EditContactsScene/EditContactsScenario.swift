//
//  EditContactsScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.12.2022.
//

import Foundation
import StackNinja

struct EditContactsScenarioInput: ScenarioEvents {   
   let onInput: Out<UserContactData>
   //
   let didChangeName: Out<String>
   let didChangeSurName: Out<String>
   let didChangeMiddleName: Out<String>
   let didSelecectGenderIndex: Out<Int>
   let didChangeEmail: Out<String>
   let didChangePhone: Out<String>
   let didChangeBirthDate: Out<Date>
   //
   let didTapBirthDateField: VoidWork
   let didTapHideYearLabel: Out<Bool>
   let didTapGenderField: VoidWork
   let didTapSaveButton: VoidWork
}

struct EditContactsScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = EditContactsScenarioInput
   typealias ScenarioModelState = EditContactsSceneState
   typealias ScenarioWorks = EditContactsWorks<Asset>
}

final class EditContactsScenario<Asset: ASP>: BaseParamsScenario<EditContactsScenarioParams<Asset>> {
   override func configure() {
      super.configure()
      
      events.onInput
         .doNext(works.storeInitialContacts)
         .onSuccess(setState) { .setFields($0) }

      events.didChangeSurName
         .doNext(TrimWhitespacesWorker())
         .doNext(StringValidateWorker(isEmptyValid: false, minSymbols: 2, maxSymbols: 32))
         .onSuccess(setState) { _ in .fieldState(.surnameField(success: true)) }
         .onFail(setState) { [.setSaveDisabled,
                              .fieldState(.surnameField(success: false))] }
         .doNext(works.updateSurName)
         .doVoidNext(works.checkThatDataChanged)
         .onSuccess(setState, .setSaveEnabled)
         .onFail(setState, .setSaveDisabled)

      events.didChangeName
         .doNext(TrimWhitespacesWorker())
         .doNext(StringValidateWorker(isEmptyValid: false, minSymbols: 2, maxSymbols: 32))
         .onSuccess(setState) { _ in .fieldState(.nameField(success: true)) }
         .onFail(setState) { [.setSaveDisabled,
                              .fieldState(.nameField(success: false))] }
         .doNext(works.updateName)
         .doVoidNext(works.checkThatDataChanged)
         .onSuccess(setState, .setSaveEnabled)
         .onFail(setState, .setSaveDisabled)

      events.didChangeMiddleName
         .doNext(TrimWhitespacesWorker())
         .doNext(StringValidateWorker(isEmptyValid: true, minSymbols: 2, maxSymbols: 32))
         .onSuccess(setState) { _ in .fieldState(.middleField(success: true)) }
         .onFail(setState) { [.setSaveDisabled,
                              .fieldState(.middleField(success: false))] }
         .doNext(works.updateMiddleName)
         .doVoidNext(works.checkThatDataChanged)
         .onSuccess(setState, .setSaveEnabled)
         .onFail(setState, .setSaveDisabled)

      events.didChangeEmail
         .doNext(TrimWhitespacesWorker())
         .doNext(EmailValidateWorker(isEmptyValid: true, minSymbols: 4))
         .onSuccess(setState) { _ in .fieldState(.emailField(success: true)) }
         .onFail(setState) { [.setSaveDisabled,
                              .fieldState(.emailField(success: false))] }
         .doNext(works.updateCorporateEmail)
         .doVoidNext(works.checkThatDataChanged)
         .onSuccess(setState, .setSaveEnabled)
         .onFail(setState, .setSaveDisabled)

      events.didChangePhone
         .doNext(TrimWhitespacesWorker())
         .doNext(FirstCharReplaceWorker(if: "7", replaceTo: "8"))
         .doNext(PhoneValidateWorker(isEmptyValid: true, minSymbols: 11, maxSymbols: 11))
         .onSuccess(setState) { _ in .fieldState(.phoneField(success: true)) }
         .onFail(setState) { [.setSaveDisabled,
                              .fieldState(.phoneField(success: false))] }
         .doNext(works.updateMobilePhone)
         .doVoidNext(works.checkThatDataChanged)
         .onSuccess(setState, .setSaveEnabled)
         .onFail(setState, .setSaveDisabled)

      events.didChangeBirthDate
         .doNext(works.updateDateOfBirth)
         .doVoidNext(works.getShowBirthday)
         .doNext(works.getDateOfBirth)
         .onSuccess(setState) { .updateDate($0) }
         .doVoidNext(works.checkThatDataChanged)
         .onSuccess(setState, .setSaveEnabled)
         .onFail(setState, .setSaveDisabled)

      events.didTapBirthDateField
         .onSuccess(setState, .scrollToEndAndPresentPicker)
      
      events.didTapHideYearLabel
         .doNext(works.updateDateOfBirthStatus)
         .doNext(works.getDateOfBirth)
         .onSuccess(setState) { .updateDate($0) }
         .doVoidNext(works.checkThatDataChanged)
         .onSuccess(setState, .setSaveEnabled)
         .onFail(setState, .setSaveDisabled)

      events.didTapGenderField
         .onSuccess(setState, .presentBirthdatePicker)

      events.didSelecectGenderIndex
         .doNext(works.updateGenderByIndex)
         .onSuccess(setState) { .updateGender($0) }
         .doVoidNext(works.checkThatDataChanged)
         .onSuccess(setState, .setSaveEnabled)
         .onFail(setState, .setSaveDisabled)

      events.didTapSaveButton
         .doNext(works.getEditedContacts)
         .onSuccess(setState) { .returnEditedContactsAndDismiss($0) }
   }
}
