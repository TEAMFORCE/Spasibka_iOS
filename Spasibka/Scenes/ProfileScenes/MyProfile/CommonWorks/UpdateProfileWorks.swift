//
//  UpdateProfileWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.12.2022.
//

// MARK: - All comments generated by OpenAI Chat GPT: https://chat.openai.com/chat

/*

 This code defines a protocol called UpdateProfileWorksProtocol which represents a group of related functions that can be used to update a user's profile. The protocol specifies that any type conforming to it must have an apiUseCase property that represents a way of calling an API, as well as several other Work properties that define functions for updating specific fields in a user's profile. The protocol also defines default implementations for these functions, which simply store the updated values in an instance of UpdateProfilePreparedData. Finally, the protocol also defines a function saveProfileData that can be used to save the updated profile data to the API.

 */

import Foundation
import StackNinja

enum UpdateProfileDataKey: String {
   // The user's Telegram name
   case telegramName = "tg_name"
   // The user's surname
   case surnName = "surname"
   // The user's first name
   case firstName = "first_name"
   // The user's middle name
   case middleName = "middle_name"
   // The user's nickname
   case nickName = "nickname"
   // The user's status
   case status
   // The user's secondary status
   case secondaryStatus = "secondary_status"
   // The user's time zone
   case timeZone = "timezone"
   // The user's birth date
   case birthDate = "date_of_birth"
   // The user's birth date year status
   case showBirthday = "show_birthday"
   // The user's job title
   case jobTitle = "job_title"
   //
   case gender
}

// This class defines a way to store and retrieve profile data
final class UpdateProfilePreparedData {
   // The dictionary that stores the profile data
   private var dataToSave: [String: Any] = [:]

   // Adds a key-value pair to the data
   func addKey(_ key: UpdateProfileDataKey, value: String) {
      dataToSave[key.rawValue] = value
   }
   
   func addAny(_ key: UpdateProfileDataKey, value: Any) {
      dataToSave[key.rawValue] = value
   }

   func addPhone(_ value: String) {
      phone = value
   }

   func addEmail(_ value: String) {
      email = value
   }

   // Returns the stored data as a dictionary
   func preparedDataInfo() -> [String: Any] {
      dataToSave
   }

   private(set) var email: String?
   private(set) var phone: String?

   // Clears the stored data
   func clearNames() {
      dataToSave = [:]
   }

   func clearContacts() {
      email = nil
      phone = nil
   }
}

protocol UpdateProfileStorageProtocol: InitClassProtocol {
   var updateData: UpdateProfilePreparedData { get }
}

protocol UpdateProfileWorksProtocol: Assetable, StoringWorksProtocol where
   Store: UpdateProfileStorageProtocol,
   Asset: AssetProtocol
{
   var apiUseCase: ApiUseCase<Asset> { get }
   //
   var updateUserContactsToTempStorage: Work<UserContactData, Void> { get }
   //
   var updateTelegramName: Work<String, Void> { get }
   var updateSurName: Work<String, Void> { get }
   var updateFirstName: Work<String, Void> { get }
   var updateMiddleName: Work<String, Void> { get }
   var updateNickName: Work<String, Void> { get }
   var updateStatus: Work<UserStatus, UserStatus> { get }
   var updateTimeZone: Work<TimeZone, Void> { get }
   var updateBirthDate: Work<Date, Void> { get }
   var updateBirthdayStatus: Work<Bool, Void> { get }
   var updateJobTitle: Work<String, Void> { get }
   //
   var saveProfileDataToServer: Work<UserData, Void> { get }
}

extension UpdateProfileWorksProtocol {
   var updateTelegramName: Work<String, Void> { .init { work in
      Self.store.updateData.addKey(.telegramName, value: work.unsafeInput)
      work.success()
   } }
   var updateSurName: Work<String, Void> { .init { work in
      Self.store.updateData.addKey(.surnName, value: work.unsafeInput)
      work.success()
   } }
   var updateFirstName: Work<String, Void> { .init { work in
      Self.store.updateData.addKey(.firstName, value: work.unsafeInput)
      work.success()
   } }
   var updateMiddleName: Work<String, Void> { .init { work in
      Self.store.updateData.addKey(.middleName, value: work.unsafeInput)
      work.success()
   } }
   var updateNickName: Work<String, Void> { .init { work in
      Self.store.updateData.addKey(.nickName, value: work.unsafeInput)
      work.success()
   } }
   var updateStatus: Work<UserStatus, UserStatus> { .init { work in
      guard let status = work.input else { work.fail(); return }
      if status == UserStatus.office || status == UserStatus.remote {
         Self.store.updateData.addKey(.status, value: status.rawValue)
      } else if status == UserStatus.working || status == UserStatus.vacation || status == UserStatus.sickLeave {
         Self.store.updateData.addKey(.secondaryStatus, value: work.unsafeInput.rawValue)
      }
      work.success(status)
   } }
   var updateTimeZone: Work<TimeZone, Void> { .init { work in
      Self.store.updateData.addKey(.timeZone, value: String(work.unsafeInput.secondsFromGMT() / 3600))
      work.success()
   } }
   var updateBirthDate: Work<Date, Void> { .init { work in
      Self.store.updateData.addKey(.birthDate, value: work.unsafeInput.convertToString(.dMMMy))
      work.success()
   } }
   
   var updateBirthdayStatus: Work<Bool, Void> { .init { work in
      Self.store.updateData.addAny(.showBirthday, value: work.unsafeInput)
      work.success()
   } }
   var updateJobTitle: Work<String, Void> { .init { work in
      Self.store.updateData.addKey(.jobTitle, value: work.unsafeInput)
      work.success()
   } }
   //
   var updateUserContactsToTempStorage: Work<UserContactData, Void> { .init { work in

      let userContactData = work.unsafeInput
      let preparedData = Self.store.updateData

      if let name = userContactData.name {
         preparedData.addKey(.firstName, value: name)
      }
      if let surname = userContactData.surname {
         preparedData.addKey(.surnName, value: surname)
      }
      if let middlename = userContactData.middlename {
         preparedData.addKey(.middleName, value: middlename)
      }

      if let dateOfBirth = userContactData.dateOfBirth {
         preparedData.addKey(.birthDate, value: dateOfBirth)
      }
      
      if let showBirthday = userContactData.showBirthday {
         preparedData.addAny(.showBirthday, value: showBirthday)
      }

      if let corporateEmail = userContactData.corporateEmail {
         preparedData.addEmail(corporateEmail)
      }

      if let mobilePhone = userContactData.mobilePhone {
         preparedData.addPhone(mobilePhone)
      }

      if let gender = userContactData.gender {
         preparedData.addKey(.gender, value: gender.rawValue)
      }

      work.success()
   } }
   //
   var saveProfileDataToServer: Work<UserData, Void> { .init { [weak self] work in
      guard let self else { work.fail(); return }

      let userData = work.unsafeInput

      if let updateNamesRequest = self.formNameContactsRequest(for: userData) {
         self.apiUseCase.updateProfile
            .doAsync(updateNamesRequest)
            .onSuccess {
               Self.store.updateData.clearNames()
               work.success()
            }
            .onFail {
               work.fail()
            }
      }

      if let updateEmailPhoneRequest = self.formFewContactsRequest(for: userData) {
         self.apiUseCase.createFewContacts
            .doAsync(updateEmailPhoneRequest)
            .onSuccess {
               Self.store.updateData.clearContacts()
               work.success()
            }
            .onFail {
               work.fail()
            }
      }
   } }
}

private extension UpdateProfileWorksProtocol {
   func formNameContactsRequest(for userData: UserData) -> UpdateProfileRequest? {
      let info = Self.store.updateData.preparedDataInfo()

      guard info.isEmpty == false else { return nil }

      let updateProfileRequest = UpdateProfileRequest(token: "",
                                                      id: userData.profile.id,
                                                      info: info)
      return updateProfileRequest
   }

   func formFewContactsRequest(for userData: UserData) -> CreateFewContactsRequest? {
      var emailId: Int?
      var phoneId: Int?
      if let contacts = userData.profile.contacts {
         for contact in contacts {
            switch contact.contactType {
            case "@":
               emailId = contact.id
            case "P":
               phoneId = contact.id
            default:
               print("Contact error")
            }
         }
      }

      var info: [FewContacts] = []

      if let email = Self.store.updateData.email {
         var emailDic = FewContacts(id: nil,
                                    contactType: "@",
                                    contactId: email)
         if let emailId = emailId {
            emailDic = FewContacts(id: emailId,
                                   contactType: "@",
                                   contactId: email)
         }
         info.append(emailDic)
      }

      if let phone = Self.store.updateData.phone {
         var phoneDic = FewContacts(id: nil,
                                    contactType: "P",
                                    contactId: phone)
         if let phoneId = phoneId {
            phoneDic = FewContacts(id: phoneId,
                                   contactType: "P",
                                   contactId: phone)
         }
         info.append(phoneDic)
      }

      guard info.isEmpty == false else { return nil }

      let createFewContactsRequest = CreateFewContactsRequest(token: "",
                                                              info: info)
      return createFewContactsRequest
   }
}