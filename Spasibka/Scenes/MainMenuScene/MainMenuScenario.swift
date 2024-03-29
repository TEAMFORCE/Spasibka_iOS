//
//  MainMenuScenario.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 24.01.2024.
//

import Foundation
import StackNinja

struct MainMenuScenarioInputEvents: ScenarioEvents {
   let reloadNewNotifies: VoidWork
   let presentHistoryScene: Out<Void>
   let presentFeedScene: Out<Void>
   let didSelectFeedItemAtIndex: Out<Int>
   let didSelectRecItemAtIndex: Out<Int>
}

final class MainMenuScenario<Asset: AssetProtocol>:
   BaseWorkableScenario<MainMenuScenarioInputEvents, MainMenuSceneState, MainMenuWorks<Asset>>, Assetable
{
   private let profileWorks = MainWorks<Asset>()

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
         .doVoidNext(works.checkThatUserDataFilledCorrectly)
         .onFail(setState, .presentUserDataNotFilledPopup)
         .doVoidNext(works.setFcmToken)
         .doNext(works.loadBalance)
         .onSuccess(setState) { .balanceDidLoad($0) }
         .onFail(setState, .loadBalanceError)
         .doVoidNext(works.getUserData)
         .onSuccess(setState) { .setUserProfileInfo($0.profile.firstName.unwrap, $0.profile.photo) }
         .doVoidNext(works.loadFilters)
         .doVoidNext(works.loadEvents)
         .onSuccess(setState) { .presentFeedSegment($0) }
         .doVoidNext(works.getRecommendations)
         .onSuccess(setState) { .presentRecommendationSegment($0) }
      
      events.reloadNewNotifies
         .doVoidNext(works.getNotificationsAmount)
         .onSuccess(setState) { .updateAlarmButtonWithNewNotificationsCount($0) }
      
      events.presentHistoryScene
         .doNext(works.getUserData)
         .onSuccess(setState) { .presentHistoryScene($0) }
      
      events.presentFeedScene
         .doNext(works.getUserData)
         .onSuccess(setState) { .presentFeedScene($0) }
      
      events.didSelectFeedItemAtIndex
         .doNext(works.getEventItem)
         .onSuccess(setState) { .routeToEvent($0) }
         .doRecover(works.getMainLinkForEventItem)
         .onSuccess(setState) { .routeToLink($0) }
      
      events.didSelectRecItemAtIndex
         .doNext(works.getRecommendationItem)
         .onSuccess(setState) { .routeToRecommendation($0) }
   }
}

