//
//  DropDownDatePickerVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 25.07.2023.
//

import StackNinja
import UIKit

final class DropDownDatePickerVM<Design: DSP>: StackModel, Designable, Eventable {
   struct Events: InitProtocol {
      var didDatePicked: Date?
      var didClearDate: Void?
   }

   var events = EventsStore()

   // MARK: - View models

   private lazy var titleLabel = LabelModel()
      .set(Design.state.label.descriptionRegular14)
      .textColor(Design.color.textSecondary)

   private lazy var titleIcon = ImageViewModel()
      .image(Design.icon.calendarLine, color: Design.color.iconMidpoint)
      .size(.square(24))
      .makeTappable()
      .userInterractionEnabled(false)
      .on(\.didTap, self) {
         $0.setState(.clearDate)
         $0.send(\.didClearDate)
         $0.collapse()
      }

   private lazy var titleWrapper = Wrapped2X(titleLabel, titleIcon)
      .height(52)
      .alignment(.center)

   private lazy var datePicker = DatePickerModel()
      .hidden(true)
      .height(160)
      .date(Date())
      .on(\.didDatePicked, self) {
         $0.setState(.currentDate($1))
         $0.send(\.didDatePicked, $1)
      }

   // MARK: - Private vars

   private var items: [String] = []
   private var isExpanded = false
   private var titleText = ""

   override func start() {
      super.start()

      arrangedModels(
         titleWrapper,
         datePicker
      )
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadiusMini)
      borderColor(Design.color.iconMidpoint)
      borderWidth(1)
      padHorizontal(16)

      titleWrapper.view
         .startTapGestureRecognize()
         .on(\.didTap, self) {
            $0.isExpanded = !$0.isExpanded
            if $0.isExpanded {
               $0.expand()
            } else {
               $0.collapse()
            }
         }
   }
}

extension DropDownDatePickerVM: StateMachine {
   enum ModelState {
      case titleText(String)
      case currentDate(Date)
      case clearDate
      case locale(Locale)
      case datePickerMode(UIDatePicker.Mode)
      case minimumDate(Date)
      case maximumDate(Date)
   }

   func setState(_ state: ModelState) {
      switch state {
      case let .titleText(text):
         titleLabel.text(text)
         titleText = text
      case let .currentDate(date):
         titleLabel.text(date.convertToString(.dMMMMy))
         datePicker.date(date)
         titleIcon.userInterractionEnabled(true)
         titleIcon.image(Design.icon.cross)
      case .clearDate:
         titleLabel.text(titleText)
         titleIcon.userInterractionEnabled(false)
         titleIcon.image(Design.icon.calendarLine)
      case let .locale(locale):
         datePicker.locale(locale)
      case let .datePickerMode(mode):
         datePicker.datePickerMode(mode)
      case let .minimumDate(date):
         datePicker.minimumDate(date)
      case let .maximumDate(date):
         datePicker.maximumDate(date)
      }
   }
}

private extension DropDownDatePickerVM {
   func expand() {
      isExpanded = true
      datePicker.hiddenAnimated(false, duration: 0.2)
   }

   func collapse() {
      isExpanded = false
      datePicker.hiddenAnimated(true, duration: 0.2)
   }
}
