//
//  DiagramProfileScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 05.12.2022.
//

import CoreLocation
import StackNinja

struct MyProfileScenarioInput: ScenarioEvents {
   let selectUserStatus: VoidWork
   let selectSecondaryStatus: VoidWork
   let settingsDidTap: VoidWork
   //
   let didSelectStatus: Out<UserStatus>
   let didSelectSecondaryStatus: Out<UserStatus>
   //
   let editContactsEvent: VoidWork
   let editLocationEvent: VoidWork
   //
   let didContactsChanged: Out<EditContactsInOut.Output>
}

struct MyProfileScenarioParams<Asset: ASP>: ScenarioParams {
   typealias ScenarioInputEvents = MyProfileScenarioInput
   typealias ScenarioModelState = MyProfileSceneState
   typealias ScenarioWorks = MyProfileWorks<Asset>
}

final class MyProfileScenario<Asset: ASP>: BaseParamsScenario<MyProfileScenarioParams<Asset>> {
   override func configure() {
      super.configure()

      start
         .doOnQueue(.globalBackground)
         //
         .doNext(works.loadMyProfileFromServer)
         .onFail(setState, .loadError)
         //
         .doVoidNext(works.getUserAvatarUrl)
         .onSuccess(setState) { .userAvatar($0) }
         //
         .doAnyway(works.getUserName)
         .onSuccess(setState) { .userName(.init(text1: "\(Asset.Design.text.hello) ",
                                                text2: $0,
                                                text3: "!")) }
         //
         .doAnyway(works.getUserStatus)
         .onSuccess(setState) { .userStatus($0) }
         //
         .doAnyway(works.getUserSecondaryStatus)
         .onSuccess(setState) { .userSecondaryStatus($0) }
         //
         .doAnyway(works.loadTagPercents)
         .doAnyway(works.getTagsPercentsData)
         .onSuccess(setState) { .tagsPercents($0) }
         //
//         .doAnyway(works.getUserLastPeriodRate)
//         .onSuccess(setState) { .userLastPeriodRate($0) }
         .doAnyway(works.getUserCurrentPeriodRate)
         .onSuccess(setState) { .userLastPeriodRate($0)}
         //
         .doAnyway(works.getUserContactsToPresent)
         .onSuccess(setState) { .userContacts($0) }
         //
         .doAnyway(works.getUserWorkData)
         .onSuccess(setState) { .userWorkPlace($0) }
         //
         .doAnyway(works.getUserRoleData)
         .onSuccess(setState) { [.userRole($0), .loaded] }

      works.startUpdatingLocation
         .doOnQueue(.globalBackground)
         .doAsync()
         .doInput([.locality, .country])
         .doNext(works.getUserLocationData)
         .onSuccess(setState) { .userLocation($0) }

      events.selectUserStatus
         .onSuccess(setState, .presentUserStatusSelector(StatusMode.main))
      
      events.selectSecondaryStatus
         .onSuccess(setState, .presentUserStatusSelector(StatusMode.secondary))

      events.didSelectStatus
         .doNext(works.updateStatus)
         .doNext(works.convertUserStatusToText)
         .onSuccess(setState) { .userStatus($0) }
         .doVoidNext(works.getStoredUserData)
         .doNext(works.saveProfileDataToServer)
      
      events.didSelectSecondaryStatus
         .doNext(works.updateStatus)
         .doNext(works.convertUserStatusToText)
         .onSuccess(setState) { .userSecondaryStatus($0) }
         .doVoidNext(works.getStoredUserData)
         .doNext(works.saveProfileDataToServer)

      events.settingsDidTap
         .doNext(works.getStoredUserData)
         .onSuccess(setState) { .presentUserSettings($0) }

      events.editContactsEvent
         .doNext(works.getUserContacts)
         .onSuccess(setState) { .presentEditContacts($0) }

      events.editLocationEvent
         .doNext(works.getStoredUserData)
         .onSuccess(setState) { .presentEditLocation($0) }

      events.didContactsChanged
         .doNext(works.updateUserContactsToTempStorage)
         .doNext(works.getStoredUserData)
         .doNext(works.saveProfileDataToServer)
         .doNext(works.loadMyProfileFromServer)
         .doAnyway(works.getUserContactsToPresent)
         .onSuccess(setState) { .userContacts($0) }
   }
}
