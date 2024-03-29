//
//  AwardDetailsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 20.12.2023.
//

import Foundation
import StackNinja

enum AwardDetailsSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = ModalDoubleStackModel<Asset>
   }

   struct InOut: InOutParams {
      typealias Input = Award
      typealias Output = Void
   }
}

final class AwardDetailsScene<Asset: ASP>: BaseParamsScene<AwardDetailsSceneParams<Asset>>, Scenarible {
   private(set) lazy var scenario = AwardDetailsScenario<Asset>(
      stateDelegate: stateDelegate,
      events: .init(input: on(\.input))
   )

   private lazy var awardImage = ImageViewModel()
      .size(.square(200))
      .contentMode(.scaleAspectFill)
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadiusBig)
      .image(Design.icon.tablerAward.insetted(8))
      .backColor(Design.color.backgroundSecondary)
   private lazy var awardTitleBadge = LabelModel()
      .set(Design.state.label.medium16)
      .width(167)
      .height(33)
      .backColor(Design.color.background)
      .padding(.horizontalOffset(16))
      .lineBreakMode(.byTruncatingTail)
      .alignment(.center)

   private lazy var awardTypeLabel = LabelModel()
      .set(Design.state.label.medium12)
      .textColor(Design.color.textSecondary)
   private lazy var awardDescriptionLabel = LabelModel()
      .set(Design.state.label.regular14)
      .textColor(Design.color.textSecondary)

   private lazy var rewardViewModel = AwardRewardViewModel<Design>()
   private lazy var rewardReceivedViewModel = ImageViewModel()
      .image(Design.icon.tablerCircleCheck, color: Design.color.success)

   private lazy var dateOfAwardReceivedTitle = LabelModel()
      .set(Design.state.label.medium12)
      .textColor(Design.color.textSecondary)
      .text(Design.text.awardReceivedDate + ":")
   private lazy var dateOfAwardReceivedLabel = LabelModel()
      .set(Design.state.label.medium12)
      .textColor(Design.color.textSecondary)
   private lazy var dateReceivedContainer = Wrapped2X(
      dateOfAwardReceivedTitle,
      dateOfAwardReceivedLabel
   )

   private lazy var mainButton = Design.button.default
   private lazy var shareButton = Design.button.brandSecondary
      .image(Design.icon.shareDefault.withTintColor(Design.color.iconBrand))
      .width(56)
      .hidden(true)

   override func start() {
      super.start()

      mainVM.closeButton.on(\.didTap, self) { $0.dismiss() }
      mainVM.bodyStack
         .arrangedModels(
            VStackModel(
               awardImage.wrappedX()
                  .cornerCurve(.continuous)
                  .cornerRadius(Design.params.cornerRadiusBig)
                  .shadow(Design.params.profileUserPanelShadow)
                  .backColor(Design.color.background),
               StackModel()
                  .addModel(
                     awardTitleBadge.wrappedX()
                        .cornerRadius(Design.params.cornerRadius)
                        .cornerCurve(.continuous)
                        .shadow(Design.params.cellShadow)
                        .zPosition(500)
                        .clipsToBound(true),
                     setup: { anchors, view in
                        anchors
                           .centerY(view.topAnchor)
                           .centerX(view.centerXAnchor)
                     }
                  )
                  .maskToBounds(false),
               Spacer(55),
               awardTypeLabel,
               Spacer(6),
               awardDescriptionLabel,
               Spacer(47),
               Wrapped2X(
                  rewardViewModel.centeredX()
                     .size(.square(44))
                     .backColor(Design.color.background)
                     .cornerRadius(44 / 2)
                     .cornerCurve(.continuous)
                     .shadow(Design.params.cellShadow)
                     .padding(.outline(6)),
                  rewardReceivedViewModel.wrappedX()
                     .size(.square(44))
                     .backColor(Design.color.background)
                     .cornerRadius(44 / 2)
                     .cornerCurve(.continuous)
                     .shadow(Design.params.cellShadow)
                     .padding(.outline(6))
               )
               .spacing(12)
               .centeredX()
            ).alignment(.center)
         )
         .axis(.horizontal)
         .alignment(.center)

      mainVM.footerStack
         .arrangedModels(
            dateReceivedContainer,
            Wrapped2X(
               mainButton,
               shareButton
            ).spacing(8)
         )
         .spacing(8)

      scenario.configureAndStart()
   }
}

enum AwardDetailsSceneState {
   case present(Award)
   case dismiss
   case error
}

extension AwardDetailsScene: StateMachine {
   func setState(_ state: AwardDetailsSceneState) {
      switch state {
      case let .present(award):
         awardTitleBadge.text(award.name.unwrap)
         awardTypeLabel.text(award.categoryName.unwrap)
         awardDescriptionLabel.text(award.description.unwrap)
         rewardViewModel.label.text(award.reward.unwrap.toString)
         dateOfAwardReceivedLabel.text(Date().convertToString(.ddMMyyyy))

         let target = award.toScore.unwrap
         let current = award.scored.unwrap
         let received = award.received.unwrap

         if received {
            mainButton.set(Design.state.button.default)
            mainButton.title(Design.text.setAwardToStatusButtonTItle)
            dateReceivedContainer.hidden(false)
        //    shareButton.hidden(false)
            mainButton.on(\.didTap, self) {
               $0.scenario.events.didTapSendToStatus.sendAsyncEvent()
            }
         } else if target == current {
            mainButton.set(Design.state.button.default)
            mainButton.title(Design.text.getAward)
            dateReceivedContainer.hidden(true)
            shareButton.hidden(true)
            mainButton.on(\.didTap, self) {
               $0.scenario.events.didTapGainAward.sendAsyncEvent()
            }
         } else {
            mainButton.set(Design.state.button.transparent)
            mainButton.title("\(current)/\(target)")
            dateReceivedContainer.hidden(true)
            shareButton.hidden(true)
            mainButton.on(\.didTap) {}
         }

         if let url = award.coverFullUrlString {
            awardImage.indirectUrl(url)
         } else {
            let iconColor = received
               ? Design.color.success
               : current == target
               ? Design.color.iconBrand
               : Design.color.iconSecondary
            awardImage.imageTintColor(iconColor)
         }
      case .dismiss:
         dismiss()
      case .error:
         break
      }
   }
}

struct AwardDetailsEvent: ScenarioEvents {
   let input: Out<Award>

   let didTapGainAward: Out<Void> = .init()
   let didShareTapped: Out<Void> = .init()
   let didTapSendToStatus: Out<Void> = .init()
}

final class AwardDetailsScenario<Asset: ASP>: BaseScenario<AwardDetailsSceneState, AwardDetailsEvent> {
   var awardId: Int?
   private let retainer = Retainer()
   private let apiUseCase = Asset.apiUseCase
   private let safeStorageUseCase = Asset.safeStorageUseCase
   private let userDefaultsWorks = Asset.userDefaultsWorks

   override func configure() {
      super.configure()

      events.input
         .onSuccess(self) {
            $0.awardId = $1.id
         }
         .onSuccess(setState) { .present($0) }

      events.didTapGainAward
         .doNext(gainAwardById)
         .onSuccess(setState, .dismiss)
         .onFail(setState, .error)

      events.didTapSendToStatus
         .doNext(setAwardToStatus)
         .onSuccess(setState, .dismiss)
         .onFail(setState, .error)
   }
}

extension AwardDetailsScenario {
   var gainAwardById: VoidWork { .init { [self] work in
      let awardId = self.awardId.unwrap
      self.safeStorageUseCase.getCurrentUserId
         .doAsync()
         .onFail {
            work.fail()
         }
         .doSaveResult()
         .doInput(UserDefaultsValue.currentOrganizationID(nil))
         .doNext(self.userDefaultsWorks.loadAssociatedValueWork())
         .onFail {
            work.fail()
         }
         .doMixSaved()
         .doMap {
            .init(orgId: $0.0, body: .init(userId: $0.1, awardId: awardId))
         }
         .doNext(self.apiUseCase.gainAward)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   } }

   var setAwardToStatus: VoidWork { .init { [self] work in
      let awardId = self.awardId.unwrap
      self.userDefaultsWorks.loadAssociatedValueWork()
         .doAsync(UserDefaultsValue.currentOrganizationID(nil))
         .doMap {
            .init(orgId: $0, body: .init(awardId: awardId))
         }
         .doNext(Asset.apiUseCase.setAwardToStatus)
         .onSuccess {
            work.success()
         }
         .onFail {
            work.fail()
         }
   }}
}

final class AwardRewardViewModel<Design: DSP>: StackNinja<SComboMR<LabelModel, ImageViewModel>>, Designable, ButtonTapAnimator {
   //
   var label: LabelModel { models.main }
   var currencyLogo: ImageViewModel { models.right }

   required init() {
      super.init()

      setAll {
         $0
            .set(Design.state.label.medium16)
            .text("0")
            .textColor(Design.color.text)
         $1
            .size(.square(17))
            .image(Design.icon.smallLogo, color: Design.color.iconBrand)
      }
      axis(.horizontal)
      alignment(.center)
      spacing(4)
   }
}
