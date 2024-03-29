//
//  ChallengeSettingScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.12.2022.
//

import StackNinja
import UIKit

struct ChallengeSettingsEvents: InitProtocol {
   var cancelled: Void?
   var continueButtonPressed: Void?
   var finishWithSuccess: Void?
   var finishWithError: Void?
}

enum ChallengeSettingsSceneState {
   case initial
   case dismissScene
   case cancelButtonPressed
   case setInputValues(ChallengeSettings)
   case updateChallengeType(ChallengeCreateLoadedParams.ChallengeType)
}

final class ChallengeSettingsScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   NavbarBodyStack<Asset, PresentBottomScheet>,
   Asset,
   ChallengeSettings,
   Void
>, Scenarible {
   private lazy var works = ChallengeSettingsWorks<Asset>()

   lazy var scenario = ChallengeSettingsScenario<Asset>(
      works: works,
      stateDelegate: stateDelegate,
      events: ChallengeSettingsScenarioEvents(
         saveInput: on(\.input),
         severalReportsTurnOn: severalReportsSwitcher.switcher.on(\.turnedOn),
         severalReportsTurnOff: severalReportsSwitcher.switcher.on(\.turnedOff),
         showCandidatesTurnOn: candidatesSwitcher.switcher.on(\.turnedOn),
         showCandidatesTurnOff: candidatesSwitcher.switcher.on(\.turnedOff),
         didSelectChallengeTypeIndex: challTypeModel.on(\.didSelectItemAtIndex),
         closeButtonTapped: mainVM.navBar.backButton.on(\.didTap)
      )
   )

   private lazy var descriptionLabel = LabelModel()
      .set(Design.state.label.descriptionRegular12)
      .text(Design.text.setLimitsIfNeeded)
      .textColor(Design.color.text)

   private lazy var cancelButton = Design.button.transparent
      .title(Design.text.cancel)

   private lazy var activityIndicator = Design.model.common.activityIndicator

   private var currentState = ChallengeSettingsSceneState.initial

   private lazy var candidatesSwitcher = LabelSwitcherPanel<Design>
      .switcherWith(text: Design.text.showApplicantsSection)

   private lazy var severalReportsSwitcher = LabelSwitcherPanel<Design>
      .switcherWith(text: Design.text.multipleReportsSection)

   private lazy var challTypeModel = DropDownSelectorVM<Design>()
      .setStates(
         .titleText(Design.text.challengeType)
      )


   // MARK: - Start

   override func start() {
      super.start()

      mainVM.navBar.titleLabel
         .text(Design.text.settings)

      mainVM.bodyStack
         .arrangedModels([
            ScrollStackedModelY()
               .spacing(20)
               .arrangedModels([
                  descriptionLabel.lefted(),
                  TitleStarredInputModel<Design, DropDownSelectorVM>(
                     title: Design.text.mode,
                     wrappedModel: challTypeModel
                  ),
                  severalReportsSwitcher,
                  candidatesSwitcher,
                  Spacer(64),
               ])
               .padding(.init(top: 0, left: 16, bottom: 0, right: 16)),
         ])

      scenario.configureAndStart()
   }
}

extension ChallengeSettingsScene: StateMachine {
   func setState(_ state: ChallengeSettingsSceneState) {
      switch state {
      case .initial:
         break
      case .dismissScene:
         dismiss()
      case .cancelButtonPressed:
         finishSucces()
         dismiss()
      case let .setInputValues(value):

         let challTypeNames = value.params.challengeTypes.map {
            switch $0 {
            case .default:
               return Design.text.defaultChallenge
            case .voting:
               return Design.text.votingChallenge
            }
         }
         challTypeModel.setStates(
            .items(challTypeNames),
            .selectIndex(value.selectedChallengeTypeIndex)
         )

         if let selectedChallengeType = value.selectedChallengeType {
            setState(.updateChallengeType(selectedChallengeType))
         } else {
            candidatesSwitcher.hidden(false)
         }

         if value.severalReports == true {
            severalReportsSwitcher.switcher.setState(.turnOn)
         }
         if value.showContenders == true {
            candidatesSwitcher.switcher.setState(.turnOn)
         }
      case let .updateChallengeType(type):
         switch type {
         case .default:
            candidatesSwitcher.hidden(false)
         case .voting:
            candidatesSwitcher.hidden(true)
         }
      }
   }
}
