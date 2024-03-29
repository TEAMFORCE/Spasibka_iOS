//
//  MainScenario.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.08.2022.
//

import StackNinja
import UIKit

struct MainScenarioInputEvents : ScenarioEvents {
   let input: Out<MainSceneInput>
   let myAvatarDidChanged: Out<UIImage>

   let sideMenuMarketplace: Out<Void>
   let sideMenuHistory: Out<Void>
   let sideMenuAnalytics: Out<Void>
   let sideMenuEmployees: Out<Void>
   let sideMenuAwards: Out<Void>

   let sideMenuSettings: Out<Void>

   let reloadNewNotifies: VoidWork
}

final class MainScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<MainScenarioInputEvents, MainSceneState, MainWorks<Asset>>, Assetable
{
   override func configure() {
      super.configure()

      start
         .doNext(works.loadProfile)
         .onFail { [weak self] in
            guard InternetRechability.isConnectedToInternet else {
               self?.setState(.loadProfileError)
               return
            }

            UserDefaults.standard.setIsLoggedIn(value: false)
            Asset.router?.route(.presentInitial, scene: \.digitalThanks, payload: ())
         }
         .doNext(works.loadBrandSettingsAndConfigureAppIfNeeded)
         .doAnyway()
         .doNext(works.getProfile)
         .onSuccess(setState) { .profileDidLoad($0) }
         .doVoidNext(works.getNotificationsAmount)
        // .onSuccess(setState) { .updateAlarmButtonWithNewNotificationsCount($0) }
         .doVoidNext(works.checkThatUserDataFilledCorrectly)
         .onFail(setState, .presentUserDataNotFilledPopup)
         .doVoidNext(works.setFcmToken)
      
      events.input
         .onSuccess(setState) { .presentChallenge($0) }

//      events.reloadNewNotifies
//         .doVoidNext(works.getNotificationsAmount)
//         .onSuccess(setState) { .updateAlarmButtonWithNewNotificationsCount($0) }
//      
//      events.myAvatarDidChanged
//         .onSuccess(setState) { .updateUserAvatarImage($0) }
      
      events.sideMenuMarketplace
         .onSuccess(setState, .presentMarketplace)
      events.sideMenuHistory
         .onSuccess(setState, .presentHistory)
      events.sideMenuEmployees
         .onSuccess(setState, .presentEmployees)
      events.sideMenuAnalytics
         .onSuccess(setState, .presentAnalytics)
      events.sideMenuAwards
         .onSuccess(setState, .presentAwards)

      events.sideMenuSettings
         .doNext(works.getUserData)
         .onSuccess(setState) { .presentSettings($0) }
   }
}
