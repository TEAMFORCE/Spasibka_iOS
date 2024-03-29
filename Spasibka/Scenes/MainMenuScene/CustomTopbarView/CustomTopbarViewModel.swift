//
//  CustomTopbarView.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 22.01.2024.
//

import StackNinja
import UIKit


final class CustomTopbarViewModel<Asset: ASP>: ViewModel, Assetable, Eventable {
   struct Events: InitProtocol {
      var didTapAvatar: Void?
      var didTapNotifications: Void?
   }
   
   var events = EventsStore()

   private(set) lazy var topBar = TopBarViewModel<Asset>()

   var isLeftBubbleOnFront: Bool = true

//    MARK: private properties

   private var isAnimating: Bool = false

   override func start() {
      setupView()
   }

//    MARK: private func

   private func setupView() {
      clipsToBound(true)
      backColor(Design.color.backgroundBrand)
      cornerRadius(Constants.cornerRadius)
      cornerCurve(.continuous)
      maskedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
//      height(Constants.viewHeight)

      addModel(topBar)

//      topBar.avatarImage
//         .makeTappable()
//         .on(\.didTap, self) {
//            $0.delegate?.tapOnAvatar()
//            Asset.router?.route(.push, scene: \.myProfile)
//         }

      view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeBubblesState(_:))))

//      topBar.notificationBell
//         .on(\.didTap, self) {
//            $0.handleNotificationTap()
//         }
   }

   @objc private func changeBubblesState(_ sender: UITapGestureRecognizer) {
      guard !isAnimating else { return }

      let coordinates = sender.location(in: view)
      if coordinates.y < 88 + topSafeAreaInset() {
         if coordinates.x > UIScreen.main.bounds.width / 2 {
            send(\.didTapNotifications)
         } else {
            send(\.didTapAvatar)
         }
      }
      
      isAnimating = true
      isLeftBubbleOnFront.toggle()

      let leftBubbleAnimations = topBar.leftBubble.getChangeStateAnimationKeyFrames()
      let rightBubbleAnimations = topBar.rightBubble.getChangeStateAnimationKeyFrames()

      UIView.animate(withDuration: Constants.animationDuration) {
         leftBubbleAnimations()
         rightBubbleAnimations()
         self.view.layoutIfNeeded()
      } completion: { _ in
         self.isAnimating = false
      }
   }

//   private func handleNotificationTap() {
//      delegate?.tapOnNotifications()
//      Asset.router?.route(.push, scene: \.notifications)
//   }
}

extension CustomTopbarViewModel {
   func setAvatar(_ image: UIImage) {
      topBar.avatarImage.image(image)
   }

   func setAvatarFromUrl(_ imageUrl: String) {
      topBar.avatarImage.url(imageUrl)
   }

   func setUsername(_ username: String) {
      topBar.userNameLabel.text(username)
   }

   func setData(leftToShare: Int, yourBalance: Int, remainingDays: Int) {
      topBar.leftBubble.setData(leftToShare)
      topBar.rightBubble.setData(yourBalance)
      topBar.setRemainingDays(count: remainingDays)
   }

   func setNotificationsCount(_ count: Int) {
      topBar.notificationBell.setNotificationsCount(count)
   }
}

extension CustomTopbarViewModel {
   enum Constants {
    //  static var viewHeight: CGFloat { 340 }
      static var cornerRadius: CGFloat { 20 }

      static var animationDuration: TimeInterval { 0.6 }

      static var avatarSize: CGSize { .init(width: 44, height: 44) }

      static var bubbleSizeLarge: CGFloat { 144 }
      static var bubbleSizeSmall: CGFloat { 96 }

      static var bubbleBorderSize: CGFloat { 22 }
   }
}
