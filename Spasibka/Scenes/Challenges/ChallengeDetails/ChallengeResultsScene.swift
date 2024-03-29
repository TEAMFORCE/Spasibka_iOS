//
//  ChallengeCandidatesScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 14.02.2024.
//

import StackNinja

struct ChallengeCandidatesSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyFooterStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = ChallengeDetailsInput
      typealias Output = Void
   }
}

final class ChallengeResultsScene<Asset: AssetProtocol>: BaseParamsScene<ChallengeCandidatesSceneParams<Asset>>,
   Scenarible
{
   lazy var scenario = ChallengeAllResultsScenario<Asset>(
      works: ChallengeDetailsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: .init(saveInputAndPrepare: on(\.input))
   )

   private lazy var descriptionBlock = M<LabelModel>.R<LabelModel>.Ninja()
      .setAll {
         $0
            .set(Design.state.label.descriptionRegular14)
            .textColor(Design.color.textSecondary)
            .text(Design.text.toChallenge)
         $1
            .set(Design.state.label.descriptionMedium14)
            .textColor(Design.color.text)
      }
      .spacing(5)
      .padHorizontal(16)
      .padBottom(16)

   enum PageKey {
      case results
      case candidates
      case winners
   }

   private(set) lazy var pageNinjaViewModel = PageNinjaViewModel<PageKey, ChallengeDetailsPageEvents, Challenge>([
      (buttonTitle: Design.text.myResult, .results, model: ChallengeResultsModel<Asset>(), isHidden: true),
      (buttonTitle: Design.text.candidates, .candidates, model: ChallengeCandidatesModel<Asset>(), isHidden: true),
      (buttonTitle: Design.text.winners, .winners, model: ChallengeWinnersModel<Asset>(), isHidden: true)
   ]) {
      return SecondaryButtonDT<Design>()
         .title($0)
         .font(Design.font.regular14)
   }

   override func start() {
      super.start()

      mainVM.navBar.titleLabel.text(Design.text.results)
      mainVM.navBar.secondaryButtonHidden(true)
      mainVM
         .bodyStack
         .arrangedModels(
            descriptionBlock.lefted(),
            pageNinjaViewModel
//            challengeCandidatesModel.viewModel
         )


      scenario.configureAndStart()
   }
}

enum ChallResultsSceneState {
   case presentChapter(ChallengeDetailsInput.Chapter)

   case enableMyResult([ChallengeResult])
   case enableContenders

   case challengeResultDidCancelled

   case votingChallenge

   case iAmOwner

   case enableWinners

   case updatePayloadForPages(Challenge)

   case error
}

extension ChallengeResultsScene: StateMachine {
   func setState(_ state: ChallResultsSceneState) {
      switch state {
      case let .updatePayloadForPages(challenge):
         descriptionBlock.models.right.text(challenge.name.unwrap)
         pageNinjaViewModel.setPayloadToCurrentPageAndStartScenario(payload: challenge)

      case .enableMyResult:
         pageNinjaViewModel.setPageHidden(.results, hidden: false)

      case .enableContenders:
         pageNinjaViewModel.setPageHidden(.candidates, hidden: false)

      case .challengeResultDidCancelled:
         pageNinjaViewModel.scrollToPage(.candidates)

      case let .presentChapter(chapter):
         switch chapter {
         case .details:
            pageNinjaViewModel.setPageHidden(.candidates, hidden: false)
            pageNinjaViewModel.scrollToPage(.candidates)
         case .winners:
            pageNinjaViewModel.setPageHidden(.winners, hidden: false)
            pageNinjaViewModel.scrollToPage(.winners)
         case .comments:
            pageNinjaViewModel.setPageHidden(.candidates, hidden: false)
            pageNinjaViewModel.scrollToPage(.candidates)
         case .report:
            pageNinjaViewModel.setPageHidden(.winners, hidden: false)
            pageNinjaViewModel.scrollToPage(.winners)
         }
      case .votingChallenge:
         pageNinjaViewModel.setPageHidden(.candidates, hidden: false)
         pageNinjaViewModel
            .getStateMachine(.candidates, type: ChallengeCandidatesModel<Asset>.self)?
            .setState(.additionalCellButtonsEnabled(false))
      case .iAmOwner:
         pageNinjaViewModel.setPageHidden(.candidates, hidden: false)
         pageNinjaViewModel.scrollToPage(.candidates, animationDuration: 0)

         pageNinjaViewModel
            .getStateMachine(.candidates, type: ChallengeCandidatesModel<Asset>.self)?
            .setState(.additionalCellButtonsEnabled(true))

      case .enableWinners:
         pageNinjaViewModel.setPageHidden(.winners, hidden: false)
         pageNinjaViewModel.scrollToPage(.winners)
      case .error:
         break
      }
   }
}
