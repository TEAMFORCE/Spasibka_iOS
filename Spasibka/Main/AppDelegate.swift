//
//  AppDelegate.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 17.06.2022.
//

import Firebase
import FirebaseCore
import FirebaseMessaging
import UIKit

import ReactiveWorks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   let gcmMessageIDKey = "gcm.Message_ID"

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      // Override point for customization after application launch.
      UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

      FirebaseApp.configure()
      FirebaseConfiguration.shared.setLoggerLevel(.min)

      UNUserNotificationCenter.current().delegate = self

      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
         options: authOptions,
         completionHandler: { _, _ in }
      )

      application.registerForRemoteNotifications()

      Messaging.messaging().delegate = self

      ReactiveWorks.isEnabledDebugThreadNamePrint = false

      return true
   }

   // MARK: UISceneSession Lifecycle

   func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
      // Called when a new scene session is being created.
      // Use this method to select a configuration to create the new scene with.
      UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
   }

   func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
      // Called when the user discards a scene session.
      // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
      // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
   }

//   func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//      VKSdk.processOpen(url, fromApplication: options[.sourceApplication] as? String)
//      return true
//   }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
   // Receive displayed notifications for iOS 10 devices.
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification) async
      -> UNNotificationPresentationOptions
   {
      let userInfo = notification.request.content.userInfo

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // ...

      // Print full message.
      print(userInfo)

      // Change this to your preferred presentation option
      return [[.banner, .sound]]
   }

   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse) async
   {
      let userInfo = response.notification.request.content.userInfo

      // ...

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print full message.
      print(userInfo)
   }

   func application(_ application: UIApplication,
                    didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult
   {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
         print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      return UIBackgroundFetchResult.newData
   }
}

extension AppDelegate: MessagingDelegate {
   func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      
      let dataDict: [String: String] = [Config.tokenKey: fcmToken ?? ""]
      NotificationCenter.default.post(
         name: NSNotification.Name("FCMToken"),
         object: nil,
         userInfo: dataDict
      )

      UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
   }
}

extension AppDelegate {
   func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
       print("Continue User Activity called: ")
       if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
           let url = userActivity.webpageURL!
           print(url.absoluteString)
       }

      return true
   }
}
