//
//  Onboarding2Scene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.05.2023.
//

import Foundation
import StackNinja

final class Onboarding2Scene<Asset: ASP>: BaseSceneExtended<Onboarding2<Asset>> {
   private lazy var stepLabel = Design.label.medium16
      .text(Design.text.step + " 2/2")

   private lazy var periodSettingsBlock = CreateOrganizationVM<Design>()
      .setStates2(.fromOnboarding)

   private lazy var descriptionBlock = LabelModel()
      .set(Design.state.label.medium14)
      .textColor(Design.color.textSecondary)
      .lineSpacing(8)
      .numberOfLines(2)
      .alignment(.center)

   private lazy var datePicker = DatePickerModel()
      .datePickerMode(.date)

   private lazy var datePickWrapper = WrappedX(datePicker)
      .borderWidth(1)
      .borderColor(Design.color.iconSecondary)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
      .hidden(true)

   private lazy var centerPopupPresenter = CenterPopupPresenter()

   private lazy var loadingScreen = DarkLoaderVM<Design>()

   override func start() {
      super.start()

      initScenario(.init(
         input: on(\.input),
         didTapStartButton: periodSettingsBlock.didTapStartButton
       //  didTapConfigModeButton: periodSettingsBlock.didTapSecondaryButton
      ))

      vcModel?.title(Design.text.periodSettings)
      mainVM.backColor(Design.color.background)

      mainVM.bodyStack
         .padding(.horizontalOffset(0))
         .padBottom(16)
         .safeAreaOffsetDisabled()
         .arrangedModels(
            ScrollStackedModelY()
               .arrangedModels(
                  Spacer(24),
                  stepLabel.centeredX(),
                  Spacer(8),
                  periodSettingsBlock,
                  Spacer(16),
                  descriptionBlock.centeredX(),
                  Spacer(16)
               )
         )

      setState(.initial)
      scenario.configureAndStart()
   }
}

extension Onboarding2Scene: StateMachine {
   func setState(_ state: ModelState) {
      switch state {
      case .initial:
         setState(.configMode(automatic: true))
         descriptionBlock.text(Design.text.startWithStandard)
         let currentDate = Date()
         let futureDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())
         let params = CommunityParams(
            name: inputValue.unwrap,
            startDate: currentDate,
            endDate: futureDate ?? currentDate,
            startBalance: 50,
            headStartBalance: 50
         )

         periodSettingsBlock.setState(.initial(params))
      case let .configMode(automatic):
         if automatic {
            periodSettingsBlock.setStates(.automatic)
         } else {
            periodSettingsBlock.setState(.manual)
         }
      case let .routeToFinishOnboarding(inviteLink):
         loadingScreen.setState(.hide)
         Asset.router?.route(
            .presentInitial,
            scene: \.onboardingFinal,
            payload: (name: inputValue.unwrap, sharingKey: inviteLink)
         )
      case .loading:
         loadingScreen.setState(.loading(onView: vcModel?.superview))
      case .loadingError:
         loadingScreen.setState(.hide)
         centerPopupPresenter.setState(
            .presentWithAutoHeight(
               model: Design.model.common.systemErrorPopup
                  .on(\.didClosed, { [weak self] in
                     self?.centerPopupPresenter.setState(.hide)
                  }),
               onView: vcModel?.superview
            )
         )
      }
   }
}
