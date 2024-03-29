//
//  TopBarViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 22.01.2024.
//

import StackNinja
import UIKit

final class TopBarViewModel<Asset: ASP>: ViewModel, Assetable {
   private(set) lazy var avatarImage = ImageViewModel()
      .image(Design.icon.avatarPlaceholder.insetted(14))
      .size(.square(Constants.avatarSizeDimension))
      .cornerRadius(Constants.avatarSizeDimension / 2)
      .backColor(Design.color.iconMidpoint)
      .contentMode(.scaleAspectFill)

   private(set) lazy var notificationBell = NotificationBellViewModel()

   private(set) lazy var leftBubble = BubbleViewModel(state: .large, secondaryText: Design.text.leftToSend)
   private(set) lazy var rightBubble = BubbleViewModel(state: .small, secondaryText: Design.text.myAccount)

   private(set) lazy var welcomingLabel = LabelModel()
      .text(Design.text.hello)
      .textColor(Design.color.constantWhite)
      .font(Design.font.descriptionRegular16)

   private(set) lazy var userNameLabel = LabelModel()
      .text(Constants.userNameLabelDefaultText)
      .textColor(Design.color.constantWhite)
      .font(Design.font.descriptionMedium16)

   private(set) lazy var welcomeUsernameStack = StackModel()
      .backColor(Design.color.transparent)
      .axis(.vertical)
      .alignment(.leading)
      .spacing(2)
      .arrangedModels(welcomingLabel, userNameLabel)

   private(set) lazy var remainingDaysLabel = LabelModel()
      .text(Design.text.remainingDayText + "\(Constants.remainingDaysDefaultNumber)" + Constants.daysText)
      .textColor(.white)
      .font(Constants.remainingDaysFont)

   private(set) lazy var bgBubbles = ImageViewModel()
      .image(Constants.bgBubblesImage)
      .contentMode(.scaleAspectFill)

   override func start() {
      super.start()

      view.on(\.didLayout, self) {
         $0.gradient(
            .init(
               colors: [
                  Design.color.backgroundBrand,
                  Design.color.backgroundBrand.darkenColor(23)
               ],
               startPoint: Constants.leftPoint,
               endPoint: Constants.rightPoint
            ),
            size: $0.view.bounds.size
         )
      }

      configure()
   }

   private func configure() {

      addModel(avatarImage) { addAnchors, parent in
         addAnchors
            .constHeight(Constants.avatarSizeDimension)
            .constWidth(Constants.avatarSizeDimension)
            .top(parent.topAnchor, topSafeAreaInset())
            .leading(parent.leadingAnchor, Constants.paddingM)
      }
      
      addModel(bgBubbles) { addAnchors, parent in
         addAnchors
            .leading(parent.leadingAnchor)
            .top(self.avatarImage.view.bottomAnchor)
            .constWidth(Constants.bgBubblesDimension)
            .constHeight(Constants.bgBubblesDimension)
      }

      addModel(welcomeUsernameStack) { addAnchors, _ in
         addAnchors
            .centerY(self.avatarImage.view.centerYAnchor)
            .leading(self.avatarImage.view.trailingAnchor, Constants.paddingM)
      }

      addModel(notificationBell) { addAnchors, parent in
         addAnchors
            .centerY(self.welcomeUsernameStack.view.centerYAnchor)
            .trailing(parent.trailingAnchor, -Constants.paddingM)
      }

      addModel(leftBubble) { addAnchors, parent in
         addAnchors
            .centerX(parent.leadingAnchor, Constants.bubbleXPositionPadding)
            .bottom(self.avatarImage.view.bottomAnchor, Constants.leftBubbleBottomPadding)
      }

      addModel(rightBubble) { addAnchors, parent in
         addAnchors
            .top(self.avatarImage.view.bottomAnchor, Constants.paddingM + 3)
            .centerX(parent.trailingAnchor, -Constants.bubbleXPositionPadding)
      }

      addModel(remainingDaysLabel) { addAnchors, parent in
         addAnchors
            .trailing(parent.trailingAnchor, -Constants.paddingL)
            .top(self.leftBubble.view.bottomAnchor)
      }
   }
}

extension TopBarViewModel {
   func setRemainingDays(count: Int) {
      remainingDaysLabel.text(Design.text.remainingDayText + "\(count) " + getDeclension(count))
   }

   private func getDeclension(_ day: Int) -> String {
      let preLastDigit = day % 100 / 10
      if preLastDigit == 1 {
         return Design.text.days
      } else {
         switch day % 10 {
         case 1:
            return Design.text.day
         case 2, 3, 4:
            return Design.text.days1
         default:
            return Design.text.days
         }
      }
   }
}

extension TopBarViewModel {
   enum Constants {
//      static var gradientColorFrirst: UIColor { .init(red: 241/255, green: 89/255, blue: 41/255, alpha: 1) }
//      static var gradientColorSecond: UIColor { .init(red: 245/255, green: 174/255, blue: 76/255, alpha: 1) }

      static var leftPoint: CGPoint { .init(x: 0, y: 0.5) }
      static var rightPoint: CGPoint { .init(x: 1, y: 0.5) }

      static var avatarSizeDimension: CGFloat { 48 }

      static var bubbleSizeL: CGFloat { CustomBubbleView.Constants.dimensionL + CustomBubbleView.Constants.borderWidth }
      static var bubbleSizeS: CGFloat { CustomBubbleView.Constants.dimensionS + CustomBubbleView.Constants.borderWidth }

//      static var leftBubbleText: String { "Осталось раздать" }
//      static var rightBubbleText: String { "Ваш баланс" }

//      static var welcomingText: String { "Привет," }
      static var userNameLabelDefaultText: String { "" }

//      static var remainingDayText: String { "До конца периода " }
      static var remainingDaysDefaultNumber: Int { 99 }
      static var daysText: String { " дней" }

      static var remainingDaysFont: UIFont { .systemFont(ofSize: 10) }
      static var usernameDefaultFont: UIFont { .systemFont(ofSize: 16, weight: .medium) }

      static var bubbleXPositionPadding: CGFloat { 18 + bubbleSizeL / 2 }
      static var leftBubbleBottomPadding: CGFloat { 160.aspected }
      static var rightBubbleTopPadding: CGFloat { 35 }

      static var paddingM: CGFloat { 16 }
      static var paddingL: CGFloat { 30 }

      static var bgBubblesDimension: CGFloat { 220 }

      static var bgBubblesImage: UIImage { UIImage(named: "Background-bubbles") ?? .init() }
   }
}
