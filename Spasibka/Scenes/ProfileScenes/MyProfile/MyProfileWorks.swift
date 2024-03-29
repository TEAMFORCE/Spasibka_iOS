//
//  DiagramProfileWorks.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 05.12.2022.
//

import CoreLocation
import StackNinja
import UIKit

final class MyProfileStorage:
   TagsDiagramStorageProtocol,
   ProfileStorageProtocol,
   UpdateProfileStorageProtocol,
   UpdateProfileAvatarStorageProtocol,
   LocationWorksStorage
{
   var updateData: UpdateProfilePreparedData = .init()
   var userData: UserData?
   var tagsPercents: [UserStat] = []

   var userLocationWork: Work<Void, CLLocation>?

   var image: UIImage?
   var croppedImage: UIImage?
}

final class MyProfileWorks<Asset: ASP>: BaseWorks<MyProfileStorage, Asset>,
   TagDiagramsWorksProtocol,
   ProfileWorksProtocol,
   UpdateProfileWorksProtocol,
   UpdateProfileAvatarWorksProtocol,
   LocationWorksProtocol
{
   lazy var apiUseCase = Asset.apiUseCase
   lazy var locationManager = LocationManager()

   var loadMyProfileFromServer: Work<Void, Void> { .init { [weak self] work in
      self?.apiUseCase.loadMyProfile
         .doAsync()
         .onSuccess {
            Self.store.userData = $0
            work.success()
         }
         .onFail {
            print("failed to load profile")
            work.fail()
         }
   }.retainBy(retainer) }

   var getUserLastPeriodRate: Work<Void, LastPeriodRate> { .init { [weak self] work in
      self?.apiUseCase.getLastPeriodRate
         .doAsync()
         .onSuccess {
            work.success($0)
         }
         .onFail {
            work.fail()
         }
   }.retainBy(retainer) }

   var getUserCurrentPeriodRate: Work<Void, LastPeriodRate> { .init { work in
      guard let currentPeriodRate = Self.store.userData?.rate else { work.fail(); return }
      let rate = LastPeriodRate(rate: currentPeriodRate)
      work.success(rate)
   }.retainBy(retainer) }
}

struct UserContactData {
   var name: String?
   var surname: String?
   var middlename: String?
   var gender: Gender?
   var corporateEmail: String?
   var mobilePhone: String?
   var dateOfBirth: String?
   var showBirthday: Bool?

//   var textForGender: String {
//      switch gender {
//      case .W:
//         return textsForGender[0]
//      case .M:
//         return textsForGender[1]
//      case .NotSelected:
//         return textsForGender[2]
//      case .none:
//         return textsForGender[2]
//      }
//   }
//
//   var textsForGender: [String] { [
//      DesignSystem.Text.woman,
//      DesignSystem.Text.man,
//      DesignSystem.Text.notIndicated,
//   ] }
}

struct UserWorkData {
   let company: String
   let department: String?
   let jobTitle: String?
}

struct UserRoleData {
   let role: String
}
