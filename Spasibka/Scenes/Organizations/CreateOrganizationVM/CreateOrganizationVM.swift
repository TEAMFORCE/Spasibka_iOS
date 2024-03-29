//
//  OnboardPage2VM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 31.05.2023.
//

import StackNinja
import UIKit

struct CommunityParams: Codable {
   var name: String?
   var startDate: Date
   var endDate: Date
   var startBalance: UInt
   var headStartBalance: UInt
   var organizationId: Int?
}

enum CreateOrganizationViewState {
   case fromOnboarding
   case fromSettings
}

extension CreateOrganizationVM: StateMachine2 {
   func setState2(_ state: CreateOrganizationViewState) {
      switch state {
      case .fromOnboarding:
         organizationNameBlock.hidden(true)
         padding(.outline(32))
         backViewModel(
            ViewModel()
               .backColor(Design.color.background)
               .cornerCurve(.continuous)
               .cornerRadius(Design.params.cornerRadiusBig)
               .userInterractionEnabled(false)
               .shadow(.init(
                  radius: 12,
                  offset: .init(x: 0, y: 6),
                  color: Design.color.iconContrast,
                  opacity: 0.19
               )),
            inset: .outline(16)
         )
      case .fromSettings:
         organizationNameBlock.hidden(false)
//         buttonModel.hidden(true)
//         buttonSecondaryModel.hidden(true)
      }
   }
}

final class CreateOrganizationVM<Design: DSP>: VStackModel, Scenarible {

   let didTapStartButton = Out<CommunityParams>()

   lazy var scenario = CreateOrganizationScenario(
      stateDelegate: stateDelegate,
      events: .init(
         initial: .init(),
         didOrgTitleChanged: organizationNameBlock.textField.on(\.didEditingChanged),
         didChangeModeTapped: buttonSecondaryModel.on(\.didTap),
         usersStartBalanceEditingChanged: headStartBalanceBlock.textField.on(\.didEditingChanged),
         headStartBalanceEditingChanged: usersStartBalanceBlock.textField.on(\.didEditingChanged),
         startDatePicked:datePickerStart.on(\.didDatePicked),
         endDatePicked:datePickerEnd.on(\.didDatePicked),
         startCreateCommunity: buttonModel.on(\.didTap)
      )
   )

   // Private

   private let organizationNameBlock = TitleTextFieldButtonVM<Design>()
      .setStates(
         .title(Design.text.title),
         .placeHolder(Design.text.title)
      )

   private let periodStartBlock = TitleTextFieldButtonVM<Design>()
      .setStates(
         .title(Design.text.periodStartDate),
         .buttonImage(Design.icon.tablerCalendar),
         .textFieldUserInterractionEnabled(false)
      )

   private let periodEndBlock = TitleTextFieldButtonVM<Design>()
      .setStates(
         .title(Design.text.periodEndDate),
         .buttonImage(Design.icon.tablerCalendar),
         .textFieldUserInterractionEnabled(false)
      )

   private let headStartBalanceBlock = TitleTextFieldButtonVM<Design>()
      .setStates(
         .title(Design.text.headStartBalance)
      )

   private let usersStartBalanceBlock = TitleTextFieldButtonVM<Design>()
      .setStates(
         .title(Design.text.usersStartBalance)
      )

   private let buttonModel = ButtonModel()
      .set(Design.state.button.default)

   private let buttonSecondaryModel = ButtonModel()
      .set(Design.state.button.brandSecondary)

   private let datePickerStart = DatePickerModel()
      .datePickerMode(.date)
      .minimumDate(Date())

   private let datePickerEnd = DatePickerModel()
      .datePickerMode(.date)
      .minimumDate(Calendar.current.date(byAdding: .day, value: 1, to: Date()))

   private lazy var datePickerStartWrapper = WrappedX(datePickerStart)
      .backColor(Design.color.background)
      .borderWidth(1)
      .borderColor(Design.color.iconSecondary)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
      .hidden(true)

   private lazy var datePickerEndWrapper = WrappedX(datePickerEnd)
      .backColor(Design.color.background)
      .borderWidth(1)
      .borderColor(Design.color.iconSecondary)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
      .hidden(true)

   private lazy var centerPopupPresenter = CenterPopupPresenter()

   private var initialParams: CommunityParams?

   private let retainer = Retainer()

   override func start() {
      super.start()

      spacing(16.aspectedByHeight)
      arrangedModels(
         organizationNameBlock,
         periodStartBlock,
         datePickerStartWrapper,
         periodEndBlock,
         datePickerEndWrapper,
         headStartBalanceBlock,
         usersStartBalanceBlock,
         Spacer(16),
         buttonModel,
         buttonSecondaryModel
      )

      setup()
      scenario.configureAndStart()
   }

   private func setup() {
      periodStartBlock.didTap
         .onSuccess(self) { slf, _ in
            slf.datePickerEndWrapper.hidden(true)
            slf.datePickerStartWrapper.hidden(!slf.datePickerStartWrapper.view.isHidden)
         }

      periodEndBlock.didTap
         .onSuccess(self) { slf, _ in
            slf.datePickerStartWrapper.hidden(true)
            slf.datePickerEndWrapper.hidden(!slf.datePickerEndWrapper.view.isHidden)
         }

      headStartBalanceBlock.textField
         .onlyDigitsMode()
         .keyboardType(.numberPad)
         .on(\.didBeginEditing, self) { slf, _ in
            slf.datePickerEndWrapper.hidden(true)
            slf.datePickerStartWrapper.hidden(true)
         }

      usersStartBalanceBlock.textField
         .onlyDigitsMode()
         .keyboardType(.numberPad)
         .on(\.didBeginEditing, self) { slf, _ in
            slf.datePickerEndWrapper.hidden(true)
            slf.datePickerStartWrapper.hidden(true)
         }
   }
}

enum Onboard2PageState {
   case initial(CommunityParams)
   case automatic
   case manual

   case createButtonEnabled
   case createButtonDisabled

   case correctEndPicker(startDate: Date)
   case correctStartPicker(endDate: Date)

   case sendCreateCommunityRequest(CommunityParams)
}

extension CreateOrganizationVM: StateMachine {
   func setState(_ state: Onboard2PageState) {
      switch state {
      case let .initial(input):
         self.initialParams = input
         scenario.events.initial.sendAsyncEvent(input)

         buttonModel.title(Design.text.start)
         periodStartBlock.setState(
            .textFieldText(input.startDate.convertToString(.ddMMyyyy))
         )
         periodEndBlock.setState(
            .textFieldText(input.endDate.convertToString(.ddMMyyyy))
         )
         headStartBalanceBlock.setState(
            .textFieldText("\(input.startBalance)")
         )
         usersStartBalanceBlock.setState(
            .textFieldText("\(input.headStartBalance)")
         )
         setState(.automatic)
      case .automatic:
         periodStartBlock.setState(.enabled(false))
         periodEndBlock.setState(.enabled(false))
         headStartBalanceBlock.setState(.enabled(false))
         usersStartBalanceBlock.setState(.enabled(false))
         buttonSecondaryModel.title(Design.text.manualConfig)
         datePickerStartWrapper.hidden(true)
         datePickerEndWrapper.hidden(true)
      case .manual:
         periodStartBlock.setState(.enabled(true))
         periodEndBlock.setState(.enabled(true))
         headStartBalanceBlock.setState(.enabled(true))
         usersStartBalanceBlock.setState(.enabled(true))
         buttonSecondaryModel.title(Design.text.automaticConfig)
      case .createButtonEnabled:
         buttonModel.set(Design.state.button.default)
      case .createButtonDisabled:
         buttonModel.set(Design.state.button.inactive)
      case let .correctEndPicker(startDate):
         datePickerEnd.minimumDate(Calendar.current.date(byAdding: .day, value: 1, to: startDate))
         periodStartBlock.setState(.textFieldText(startDate.convertToString(.ddMMyyyy)))
      case let .correctStartPicker(endDate):
         datePickerStart.maximumDate(Calendar.current.date(byAdding: .day, value: -1, to: endDate))
         periodEndBlock.setState(.textFieldText(endDate.convertToString(.ddMMyyyy)))
      case .sendCreateCommunityRequest(let params):
         didTapStartButton.sendAsyncEvent(params)
      }
   }
}
