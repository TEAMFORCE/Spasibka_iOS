//
//  MyProfileWorksProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.12.2022.
//

import CoreLocation
import StackNinja

protocol ProfileWorksProtocol: StoringWorksProtocol, Assetable where
   Store: ProfileStorageProtocol,
   Asset: AssetProtocol
{
   var apiUseCase: ApiUseCase<Asset> { get }
   //
   var getStoredUserData: Work<Void, UserData> { get }
   //
   var getUserAvatarUrl: Work<Void, String> { get }
   var getUserName: Work<Void, String> { get }
   var getUserSurname: Work<Void, String> { get }
   var getUserStatus: Work<Void, String> { get }
   var getUserContacts: Work<Void, UserContactData> { get }
   var getUserWorkData: Work<Void, UserWorkData> { get }
   var getUserRoleData: Work<Void, UserRoleData> { get }
}

extension ProfileWorksProtocol {

   // MARK: - getters

   var getStoredUserData: Work<Void, UserData> { .init { work in
      guard let data = Self.store.userData else { work.fail(); return }

      work.success(data)
   } }

   var getUserAvatarUrl: Work<Void, String> { .init { work in
      guard let photo = Self.store.userData?.profile.photo else { work.fail(); return }

      work.success(photo)
   } }

   var getUserName: Work<Void, String> { .init { work in
      guard let userData = Self.store.userData else { work.fail(); return }

      work.success(userData.profile.firstName.unwrap)
   }}

   var getUserSurname: Work<Void, String> { .init { work in
      guard let userData = Self.store.userData else { work.fail(); return }

      work.success(userData.profile.surName.unwrap)
   }}

   func getStatusText(value: UserStatus?) -> String {
      var res = ""
      switch value {
      case .vacation:
         res = Design.text.vactionStatus
      case .working:
         res = Design.text.workingStatus
      case .sickLeave:
         res = Design.text.sickLeaveStatus
      case .remote:
         res = Design.text.remoteStatus
      case .office:
         res = Design.text.inOfficeStatus
      case .none:
         res = ""
      }
      return res
   }
   
   var convertUserStatusToText: Work<UserStatus, String> { .init { [weak self] work in
      guard let value = work.input else { work.fail(); return }
      let res = self?.getStatusText(value: value)
      work.success(res ?? "")
   }.retainBy(retainer) }
   
   var getUserStatus: Work<Void, String> { .init { work in
      guard
         let statusCode = Self.store.userData?.profile.status
         //let status = UserStatus(rawValue: statusCode)?.text()
      else { work.success(Design.text.notIndicated); return }

      let value = UserStatus(rawValue: statusCode)
      let res = self.getStatusText(value: value)
      work.success(res)
   }.retainBy(retainer) }
   
   var getUserSecondaryStatus: Work<Void, String> { .init { work in
      guard
         let secondaryStatusCode = Self.store.userData?.profile.secondaryStatus
//         let secondaryStatus = UserStatus(rawValue: secondaryStatusCode)?.text()
      else { work.success(Design.text.notIndicated); return }
      let value = UserStatus(rawValue: secondaryStatusCode)
      let res = self.getStatusText(value: value)
      work.success(res)
   }.retainBy(retainer) }

   func getDateOfBirth(showYear: Bool?, date: String?) -> String? {
      return showYear == true ? date?.dateFormatted(.dMMMy) : date?.dateFormatted(.ddMM)
   }
   
   var getUserContacts: Work<Void, UserContactData> { .init { work in
      guard let userData = Self.store.userData else { work.fail(); return }
      let profile = userData.profile
      let contacts = UserContactData(
         name: profile.firstName,
         surname: profile.surName,
         middlename: profile.middleName,
         gender: profile.gender,
         corporateEmail: userData.userEmail,
         mobilePhone: userData.userPhone,
         dateOfBirth: userData.profile.birthDate?.dateFormatted(.dMMMy),
         showBirthday: userData.profile.showBirthday
      )

      work.success(contacts)
   } }
   
   var getUserContactsToPresent: Work<Void, UserContactData> { .init { work in
      guard let userData = Self.store.userData else { work.fail(); return }
      let profile = userData.profile
      let dateOfBirth = self.getDateOfBirth(showYear: userData.profile.showBirthday,
                                       date: userData.profile.birthDate)

      let contacts = UserContactData(
         name: profile.firstName,
         surname: profile.surName,
         middlename: profile.middleName,
         gender: profile.gender,
         corporateEmail: userData.userEmail,
         mobilePhone: userData.userPhone,
         dateOfBirth: dateOfBirth,
         showBirthday: userData.profile.showBirthday
      )

      work.success(contacts)
   } }


   var getUserWorkData: Work<Void, UserWorkData> { .init { work in
      guard let userData = Self.store.userData else { work.fail(); return }

      let workPlaceData = UserWorkData(
         company: userData.profile.organization,
         department: userData.profile.department,
         jobTitle: userData.profile.jobTitle
      )

      work.success(workPlaceData)
   } }

   var getUserRoleData: Work<Void, UserRoleData> { .init { work in
      guard let userData = Self.store.userData else { work.fail(); return }
      
      let role = userData.privileged.first?.roleName
      let userRoleData = UserRoleData(role: role ?? Design.text.notIndicated)
      // TODO: - Fish yet

      print(userRoleData)
      work.success(userRoleData)
   } }
}
