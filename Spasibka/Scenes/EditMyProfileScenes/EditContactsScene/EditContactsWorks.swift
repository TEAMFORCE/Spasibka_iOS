//
//  EditContactsWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.12.2022.
//

import Foundation
import StackNinja

protocol EditContactsStorageProtocol: InitClassProtocol {
   var initialContacts: UserContactData { get set }
   var editedContacts: UserContactData { get set }
   var updateShowBirthdayCounter: Int { get set }
}

final class EditContactsStorage: EditContactsStorageProtocol {
   var initialContacts: UserContactData = .init()
   var editedContacts: UserContactData = .init()
   var updateShowBirthdayCounter = 0
}

protocol EditContactsWorksProtocol: StoringWorksProtocol where Store: EditContactsStorageProtocol {
   var storeInitialContacts: Work<UserContactData, UserContactData> { get }
   //
   var updateSurName: Work<String, String> { get }
   var updateName: Work<String, String> { get }
   var updateMiddleName: Work<String, String> { get }
   var updateCorporateEmail: Work<String, String> { get }
   var updateMobilePhone: Work<String, String> { get }
   var updateDateOfBirth: Work<Date, String> { get }
   //
   var checkThatDataChanged: Work<Void, Void> { get }
   //
   var getEditedContacts: Work<Void, UserContactData> { get }
}

extension EditContactsWorksProtocol {
   var storeInitialContacts: Work<UserContactData, UserContactData> { .init { work in
      Self.store.initialContacts = work.unsafeInput
      Self.store.editedContacts = .init()
      work.success(work.unsafeInput)
   }.retainBy(retainer) }
   //
   var updateSurName: Work<String, String> { .init {
      Self.store.editedContacts.surname = $0.unsafeInput
      $0.success($0.unsafeInput)
   }.retainBy(retainer) }

   var updateName: Work<String, String> { .init {
      Self.store.editedContacts.name = $0.unsafeInput
      $0.success($0.unsafeInput)
   }.retainBy(retainer) }

   var updateMiddleName: Work<String, String> { .init {
      Self.store.editedContacts.middlename = $0.unsafeInput
      $0.success($0.unsafeInput)
   }.retainBy(retainer) }

   var updateCorporateEmail: Work<String, String> { .init {
      Self.store.editedContacts.corporateEmail = $0.unsafeInput
      $0.success($0.unsafeInput)
   }.retainBy(retainer) }

   var updateMobilePhone: Work<String, String> { .init {
      Self.store.editedContacts.mobilePhone = $0.unsafeInput
      $0.success($0.unsafeInput)
   }.retainBy(retainer) }

   var updateDateOfBirth: Work<Date, String> { .init {
      let dateStr = $0.unsafeInput.convertToString(.dMMMy)
      Self.store.editedContacts.dateOfBirth = dateStr
      $0.success(dateStr)
   }.retainBy(retainer) }

   var updateDateOfBirthStatus: Work<Bool, Bool> { .init { work in
      guard let status = work.input else { work.fail(); return }
      Self.store.editedContacts.showBirthday = status
      Self.store.updateShowBirthdayCounter += 1
      if Self.store.updateShowBirthdayCounter < 2 {
         work.fail() 
      } else {
         work.success(status)
      }
   }.retainBy(retainer) }
   
   var updateGenderByIndex: In<Int>.Out<Gender> { .init { work in
      let gender = Gender(index: work.in)
      Self.store.editedContacts.gender = gender
      work.success(gender)
   }}
   //
   
   func getDateOfBirth(showYear: Bool?, date: String?) -> String? {
      var res: String? = nil
      if showYear == true {
         res = date?.dateConverted(inputFormat: .ddMM, outputFormat: .dMMMy)
         if res == nil {
            res = date?.dateConverted(inputFormat: .dMMMy, outputFormat: .dMMMy)
         }
      } else {
         res = date?.dateConverted(inputFormat: .dMMMy, outputFormat: .ddMM)
         if res == nil {
            res = date?.dateConverted(inputFormat: .ddMM, outputFormat: .ddMM)
         }
      }
//      let fullDate = date?.dateConverted(inputFormat: .dMMMy, outputFormat: .dMMMy)
//      let shortDate = date?.dateConverted(inputFormat: .dMMMy, outputFormat: .ddMM)
//      return showYear == true ? fullDate : shortDate
      return res
   }
   
   var getShowBirthday: Work<Void, Bool> { .init { work in
      var showBirthday = Self.store.initialContacts.showBirthday
      if let edited = Self.store.editedContacts.showBirthday {
         showBirthday = edited
      }
      work.success(showBirthday ?? true)
   }.retainBy(retainer) }
   
   var getDateOfBirth: Work<Bool, String> { .init { work in
      guard let hideYear = work.input else { work.fail(); return }
      var date = Self.store.initialContacts.dateOfBirth
      if let newDate = Self.store.editedContacts.dateOfBirth {
         date = newDate
      }
      if let res = self.getDateOfBirth(showYear: !hideYear, date: date) {
         work.success(res)
      } else {
         work.fail()
      }
   }.retainBy(retainer) }
   
   var checkThatDataChanged: Work<Void, Void> { .init {
      let initial = Self.store.initialContacts
      let edited = Self.store.editedContacts
      
      let changed =
         initial.surname.unwrap != edited.surname.unwrap ||
         initial.name.unwrap != edited.name.unwrap ||
         initial.middlename.unwrap != edited.middlename.unwrap ||
         initial.corporateEmail.unwrap != edited.corporateEmail.unwrap ||
         initial.mobilePhone.unwrap != edited.mobilePhone.unwrap ||
         initial.dateOfBirth.unwrap != edited.dateOfBirth.unwrap ||
         initial.showBirthday.unwrap != edited.showBirthday.unwrap ||
         initial.gender != edited.gender

      if changed {
         $0.success()
      } else {
         $0.fail()
      }
   }.retainBy(retainer) }
   //
   var getEditedContacts: Work<Void, UserContactData> { .init {
      if let dateOfBirth = Self.store.editedContacts.dateOfBirth {
         Self.store.editedContacts.dateOfBirth = dateOfBirth.dateConverted(inputFormat: .dMMMy, outputFormat: .yyyyMMdd)
      }
      if let showBirthday = Self.store.editedContacts.showBirthday {
         Self.store.editedContacts.showBirthday = !(showBirthday)
      }
      $0.success(Self.store.editedContacts)
   }.retainBy(retainer) }
}

final class EditContactsWorks<Asset: ASP>: BaseWorks<EditContactsStorage, Asset>, EditContactsWorksProtocol {}

