//
//  DatePickerModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.04.2023.
//

import UIKit
import StackNinja

struct DatePickerEvents: InitProtocol {
   var didDatePicked: Date?
}

class DatePickerModel: BaseViewModel<UIDatePicker> {
   var events: EventsStore = .init()

   override func start() {
      if #available(iOS 13.4, *) {
         view.preferredDatePickerStyle = .wheels
         view.overrideUserInterfaceStyle = .light
      } else {
         // Fallback on earlier versions
      }
      view.locale = .autoupdatingCurrent //Locale(identifier: "ru_RU")
      view.datePickerMode = .dateAndTime
      view.addTarget(self, action: #selector(didDatePicked), for: .valueChanged)
   }

   @objc private func didDatePicked() {
      send(\.didDatePicked, view.date)
   }
}

extension DatePickerModel {

   @discardableResult
   func date(_ value: Date) -> Self {
      view.date = value
      return self
   }

   @discardableResult
   func locale(_ value: Locale) -> Self {
      view.locale = value
      return self
   }

   @discardableResult
   func datePickerMode(_ value: UIDatePicker.Mode) -> Self {
      view.datePickerMode = value
      return self
   }

   @discardableResult
   func minimumDate(_ value: Date?) -> Self {
      view.minimumDate = value
      return self
   }

   @discardableResult
   func maximumDate(_ value: Date?) -> Self {
      view.maximumDate = value
      return self
   }
}

extension DatePickerModel: Eventable {
   typealias Events = DatePickerEvents
}
