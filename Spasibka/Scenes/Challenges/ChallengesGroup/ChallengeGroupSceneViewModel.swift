//
//  ChallengeGroupScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.09.2023.
//

import StackNinja

final class ChallengeGroupSceneViewModel<Asset: AssetProtocol>: VStackModel,
   Eventable,
   Assetable,
   Scenarible
{
   typealias Events = MainSceneEvents<UserData?>
   var events: EventsStore = .init()

   // MARK: - Scenario

   private(set) lazy var scenario = ChallengeGroupScenario(
      works: ChallengeGroupWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: ChallengeGroupScenarioInputEvents(
         didTabSettings: .init(),
         didTapAllChallenges: .init(),
         didTapAllChallengeChains: .init()
      )
   )

   // MARK: - View Models

   private lazy var challengeChainsPreview = ChallengeChainsViewModel<Asset>()
      .height(190)

   private lazy var segmentControl = SegmentControl<Button3Event>(
      buttons:
      SegmentButton<Design>()
         .title(Design.text.challenges)
         .font(Design.font.regular14),
      SegmentButton<Design>()
         .title(Design.text.challengeChains)
         .font(Design.font.regular14),
      SegmentButton<Design>()
         .title(Design.text.сhallengeTemplates)
         .font(Design.font.regular14)
   )
   .cornerRadius(Design.params.cornerRadiusSmall)
   .cornerCurve(.continuous)
   .clipsToBound(true)
   .maskToBounds(true)

   lazy var challengesScene = ChallengesMainViewModel<Asset>()
      .on(\.didScroll) { [weak self] in
         self?.send(\.didScroll, $0)
      }
      .on(\.willEndDragging) { [weak self] in
         self?.send(\.willEndDragging, $0)
         if $0 > 0 {
            self?.challengeChainsPreview.hidden(true, isAnimated: true)
         } else if $0 < 0 {
            self?.challengeChainsPreview.hidden(false, isAnimated: true)
         }
      }

   // MARK: - Start

   override func start() {
      padding(.horizontalOffset(0))
      scenario.configureAndStart()

      arrangedModels(
         makeSectionHeader(
            Design.text.challengeChains,
            tapEvent: scenario.events.didTapAllChallengeChains
         ),
         challengeChainsPreview,
         makeSectionHeader(
            Design.text.challenges,
            tapEvent: scenario.events.didTapAllChallenges
         ),
         challengesScene
      )

      challengesScene.scenarioStart()
      challengeChainsPreview.scenarioStart()
   }
}

extension ChallengeGroupSceneViewModel {
   private func makeSectionHeader(_ title: String, tapEvent: Out<Void>) -> UIViewModel {
      let sectionHeader = M<LabelModel>.R<ButtonModel>.Ninja()
         .setAll {
            $0
               .set(Design.state.label.descriptionMedium14)
               .textColor(Design.color.text)
               .text(title)
            $1
               .font(Design.font.descriptionMedium14)
               .textColor(Design.color.textInfo)
               .title(Design.text.all1)
               .setNeedsStoreModelInView()
               .on(\.didTap) { tapEvent.sendAsyncEvent() }
         }
         .padHorizontal(16)
         .padTop(16)
         .padBottom(12)

      return sectionHeader
   }
}

enum ChallengeGroupState {
   case presentAllChallenges
   case presentAllChallengeChains
}

extension ChallengeGroupSceneViewModel: StateMachine {
   func setState(_ state: ChallengeGroupState) {
      switch state {
      case .presentAllChallenges:
         Asset.router?.route(.push, scene: \.challenges)
      case .presentAllChallengeChains:
         Asset.router?.route(.push, scene: \.challengeChains)
      }
   }
}
