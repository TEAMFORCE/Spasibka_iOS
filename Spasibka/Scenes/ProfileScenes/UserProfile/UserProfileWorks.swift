//
//  UserProfileWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.12.2022.
//

import StackNinja
import CoreLocation

final class UserProfileStorage:
   TagsDiagramStorageProtocol,
   ProfileStorageProtocol
{
   var updateData: UpdateProfilePreparedData = .init()
   var userData: UserData?
   var tagsPercents: [UserStat] = []
}

final class UserProfileWorks<Asset: ASP>: BaseWorks<UserProfileStorage, Asset>,
   TagDiagramsWorksProtocol,
   ProfileWorksProtocol
{
   var apiUseCase = Asset.apiUseCase

   private lazy var geocoder = CLGeocoder()

   var loadProfileById: Work<ProfileID, Void> { .init { [weak self] work in
      self?.apiUseCase.getProfileById
         .doAsync(work.unsafeInput)
         .onSuccess {
            Self.store.userData = $0
            work.success()
         }
         .onFail {
            print("failed to load profile")
            work.fail()
         }
   } }

   var getUserLocationData: Work<CLLocation, UserLocationData> { .init { [weak self] work in

      let location = work.unsafeInput

      self?.geocoder.reverseGeocodeLocation(location) { placemarks, error in
         if let _ = error {
            work.fail()
         } else if let placemarks = placemarks {
            let placemark = placemarks.first
            let result = UserLocationData(
               locationName: (placemark?.locality).unwrap,
               geoPosition: location.coordinate
            )

            work.success(result)
         }
      }
   } }

   var getUserContacts: Work<Void, UserContactData> { .init { work in
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
         dateOfBirth: dateOfBirth //userData.profile.birthDate?.dateFormatted(.ddMM)
      )

      work.success(contacts)
   } }
   
   func getDateOfBirth(showYear: Bool?, date: String?) -> String? {
      return showYear == true ? date?.dateFormatted(.ddMMyyyy) : date?.dateFormatted(.ddMM)
   }
   
   var getUserId: Work<Void, Int> { .init { work in
      guard let id = Self.store.userData?.id else { work.fail(); return }
      work.success(id)
   } }
}
