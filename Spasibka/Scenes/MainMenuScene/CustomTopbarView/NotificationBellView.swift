//
//  NotificationBellView.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 23.01.2024.
//

import StackNinja
import UIKit

final class NotificationBellViewModel: BaseViewModel<NotificationBellView>, Eventable {
   typealias Events = ButtonEvents

   var events = EventsStore()

   override func start() {
      super.start()
      view.setupView()
      
      addModel(
         ButtonModel()
            .setNeedsStoreModelInView()
            .on(\.didTap, self) {
               $0.send(\.didTap)
            }
      )
   }

   func setNotificationsCount(_ count: Int) {
      view.setNotificationsCount(count)
   }
   func setBlackIcon() {
      view.setBlackIcon()
   }
}

final class NotificationBellView: UIView {
//    MARK: exposed properties

   var notificationsCount: Int = 0 {
      didSet {
         setCounterLabel()
      }
   }

//    MARK: private view components

   private lazy var icon: UIImageView = {
      let view = UIImageView()
      view.contentMode = .scaleAspectFill
      view.image = Constants.bellIcon
      NSLayoutConstraint.activate([
         view.widthAnchor.constraint(equalToConstant: Constants.iconWidth),
         view.heightAnchor.constraint(equalToConstant: Constants.iconHeight)
      ])
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
   }()

   private lazy var counterBG: UIView = {
      let view = UIView()
      view.backgroundColor = .systemRed
      view.layer.cornerRadius = Constants.counterBGDimension / 2
      NSLayoutConstraint.activate([
         view.widthAnchor.constraint(equalToConstant: Constants.counterBGDimension),
         view.heightAnchor.constraint(equalToConstant: Constants.counterBGDimension)
      ])
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
   }()

   private lazy var counterLabel: UILabel = {
      let label = UILabel()
      label.font = Constants.counterLabelFont
      label.textColor = .white
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
   }()

//    MARK: private func

   func setupView() {
      translatesAutoresizingMaskIntoConstraints = false

      addSubview(icon)
      addSubview(counterBG)
      addSubview(counterLabel)

      NSLayoutConstraint.activate([
         widthAnchor.constraint(equalToConstant: Constants.viewDimension),
         heightAnchor.constraint(equalToConstant: Constants.viewDimension),

         icon.centerYAnchor.constraint(equalTo: centerYAnchor),
         icon.centerXAnchor.constraint(equalTo: centerXAnchor),

         counterBG.centerYAnchor.constraint(equalTo: icon.topAnchor),
         counterBG.centerXAnchor.constraint(equalTo: icon.trailingAnchor),

         counterLabel.centerYAnchor.constraint(equalTo: counterBG.centerYAnchor),
         counterLabel.centerXAnchor.constraint(equalTo: counterBG.centerXAnchor)
      ])

      setCounterLabel()
   }
}

extension NotificationBellView {
   enum Constants {
      static let iconWidth: CGFloat = 18
      static let iconHeight: CGFloat = 19.5
      static let bellIcon: UIImage? = UIImage(named: "Notification-icon")
      static let bellIconBlack: UIImage? = UIImage(named: "Notification-icon")?.withTintColor(.black)

      static let counterBGDimension: CGFloat = 15

      static let viewDimension: CGFloat = 44

      static let counterLabelFont: UIFont = UIFont.systemFont(ofSize: 10)

      static let moreThan99Text = "99+"
   }
}

extension NotificationBellView {
   func setNotificationsCount(_ count: Int) {
      notificationsCount = count
   }

   func setBlackIcon() {
      icon.image = Constants.bellIconBlack
   }

   private func setCounterLabel() {
      switch notificationsCount {
      case Int.min ... 0:
         counterLabel.alpha = 0
         counterBG.alpha = 0

      case 1 ... 99:
         counterLabel.alpha = 1
         counterBG.alpha = 1
         counterLabel.text = "\(notificationsCount)"

      default:
         counterLabel.alpha = 1
         counterBG.alpha = 1
         counterLabel.text = Constants.moreThan99Text
      }
   }
}
