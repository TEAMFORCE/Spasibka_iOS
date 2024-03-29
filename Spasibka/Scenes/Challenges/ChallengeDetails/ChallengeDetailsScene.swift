//
//  ChallengeDetailsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 09.10.2022.
//

import StackNinja
import UIKit

enum ChallengeDetailsInput {
   case byChallenge(Challenge, chapter: Chapter = .details)
   case byFeed(Feed, chapter: Chapter = .details)
   case byId(Int, chapter: Chapter = .details)

   enum Chapter {
      case details
      case winners
      case comments
      case report(id: Int)
   }
}

enum FinishEditChallengeEvent {
   case didCreate
   case didEdit
   case didDelete
}

struct ChallengeDetailsPageEvents: ScrollEventsProtocol {
   var willEndDragging: (velocity: CGFloat, offset: CGFloat)?
   var didScroll: (velocity: CGFloat, offset: CGFloat)?

   var didResultCancel: Void?
   var didTapCopyButton: Void?
}

final class ChallengeDetailsScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   AnimatedHeaderNavbarBodyFooterStack<Asset>,
   Asset,
   ChallengeDetailsInput,
   Void
> {
   //
   private(set) lazy var scenario = ChallengeDetailsScenario(
      works: ChallengeDetailsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: ChallengeDetailsInputEvents(
         saveInputAndLoadChallenge: on(\.input),
         challengeResultDidSend: .init(),
         challengeResultDidCancelled: .init(),
         editButtonTapped: reactionsBlock.editChallengeButton.on(\.didTap),
         shareButtonTapped: reactionsBlock.shareButton.on(\.didTap),
         didFinishChallengeOperation: .init(),
         reactionPressed: reactionsBlock.likesBlock.button.on(\.didTap),
         didTapComments: reactionsBlock.commentsBlock.button.on(\.didTap),
         sendChallengeResult: buttonsPanel.sendButton.on(\.didTap),
         didTapAllResults: buttonsPanel.resultsButton.on(\.didTap),
         didTapAllReactions: .init()
      )
   )

   // Default header image

   var headerHeightConstraint: NSLayoutConstraint?

   var headerBrightness = ColorBrightnessStyle.dark

   let headerTitle = Design.text.challenge

   private(set) lazy var headerViewModel = ChallengeChainHeaderVM<Design>(
      placeholder: Design.icon.challengeWinnerIllustrateFull,
      backColor: Design.color.backgroundBrand
   )
   .addModel(usersButtonBlock) {
      $0
         .left($1.leftAnchor, 16)
         .top($1.topAnchor, 64)
         .bottom($1.bottomAnchor, -42)
   }
   .addModel(reactionsBlock) {
      $0
         .fitToTopRight($1, offset: 64, sideOffset: 16)
   }

   private lazy var usersButtonBlock = ChallengeChainUsersButtonBlock<Asset>()
   private lazy var reactionsBlock = ChallengeChainReactionsBlock<Design>()

   private lazy var challengeDetailsModel = ChallengeDetailsModel<Asset>()

   private lazy var buttonsPanel = ChallResultsButtonsPanel<Design>()
      .padding(.horizontalOffset(Design.params.commonSideOffset))

//   private lazy var statusLabel = LabelModel()
//      .set(Design.state.label.regular12)
//      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusMini)
//      .height(Design.params.buttonHeightMini)
//      .textColor(Design.color.textInvert)
//      .padding(.horizontalOffset(8))

   private lazy var errorBlock = Design.model.common.connectionErrorBlock
      .hidden(true)

   enum PageKey {
      case details
      case reactions
   }

   private lazy var footerButton = Design.button.default
      .font(Design.font.descriptionMedium12)
      .title(Design.text.results)

   // other

   private lazy var darkLoader = DarkLoaderVM<Design>()

   override func start() {
      super.start()

      setState(.presentActivityIndicator)

      bindPageEvents()

      vcModel?.on(\.viewWillAppear, self) {
         $0.setNavBarInvisible()
      }

      mainVM.footerStack
         .hidden(true)

      mainVM
         .addModel(buttonsPanel) { $0.fitToBottom($1) }

      usersButtonBlock.button.hidden(true)

      mainVM.headerStack
         .arrangedModels([
            headerViewModel
         ])

      mainVM.navBar
         .titleLabel.text(Design.text.challenge)

      mainVM.bodyStack
         .arrangedModels(
            errorBlock,
            challengeDetailsModel.viewModel
         )
         .padTop(0)
         .backColor(Design.color.background)

      mainVM.footerStack
         .backColor(Design.color.background)
         .arrangedModels(
            footerButton.hidden(true)
         )
         .padding(.outline(16))

      vcModel?.on(\.viewWillAppearByBackButton, self) {
         if $0.isHeaderPresented {
            $0.presentHeaderAll()
         } else {
            $0.hideHeaderAll()
         }
      }

      reactionsBlock.likesBlock.view
         .addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongTapToLikes)))

      scenario.configureAndStart()

      presentHeaderAll()
   }

   private func presentSharing(link: String?) {
      guard let objectsToShare = URL(string: link ?? "") else { return }
      darkLoader.setState(.loading(onView: vcModel?.superview))

      let sharedObjects: [AnyObject] = [objectsToShare as AnyObject]
      let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
      activityViewController.popoverPresentationController?.sourceView = vcModel?.view

      activityViewController.excludedActivityTypes = [
         UIActivity.ActivityType.postToFacebook
      ]
      vcModel?.present(activityViewController, animated: true) { [weak self] in
         self?.darkLoader.setState(.hide)
      }
   }

   @objc func didLongTapToLikes() {
      scenario.events.didTapAllReactions.sendAsyncEvent()
   }

   func bindPageEvents() {
      challengeDetailsModel.viewModel.scrollModel.on(\.willEndDragging, self) {
         if $1.velocity <= 0, !$0.isHeaderPresented {
            $0.presentHeaderAll()
         } else if $1.velocity > 0, $0.isHeaderPresented {
            $0.hideHeaderAll()
         }
      }
   }

   private func presentHeaderAll() {
      presentHeader { [usersButtonBlock, reactionsBlock] in
         usersButtonBlock.alpha(1)
         reactionsBlock.alpha(1)
      }
   }

   private func hideHeaderAll() {
      hideHeader { [usersButtonBlock, reactionsBlock] in
         usersButtonBlock.alpha(0)
         reactionsBlock.alpha(0)
      }
   }
}

enum ChallengeDetailsState {
   case initial

   case presentChapter(ChallengeDetailsInput.Chapter)

   case presentActivityIndicator
   case error

   case setHeaderImage(UIImage?)

   case presentSendResultScreen(Challenge)
   case resultSentSuccessfully

   case enableMyResult([ChallengeResult])
   case enableContenders

   case challengeResultDidCancelled

   case presentReportDetailView(Int)

   case votingChallenge

   case iAmOwner

   case enableWinners

   case presentChallengeEdit(Challenge)
   case activateEditButton
   case presentShareView(String)

   // new
   case updatePayloadForPages(Challenge)

   case challengeDeleted

   case buttonLikePressed(alreadySelected: Bool)
   case failedToReact(alreadySelected: Bool)
   case updateLikesAmount(Int)

   case commentsCount(Int)

   case presentComments(Challenge)

   case presentAllResults(ChallengeDetailsInput)

   case presentAllReactions(Challenge)
}

extension ChallengeDetailsScene: StateMachine {
   func setState(_ state: ChallengeDetailsState) {
      switch state {
      case .initial:
         break

      case .presentActivityIndicator:
         break

      case let .presentSendResultScreen(challenge):
         Asset.router?.route(
            .push,
            scene: \.challengeSendResult,
            payload: challenge.id,
            finishWork: scenario.events.challengeResultDidSend
         )

      case .resultSentSuccessfully:
//         pageNinjaViewModel.setPageHidden(.results, hidden: false)
//         pageNinjaViewModel.scrollToPage(.results)
         break

      case .enableMyResult:
         break
//         pageNinjaViewModel.setPageHidden(.results, hidden: false)

      case .enableContenders:
         break
//         pageNinjaViewModel.setPageHidden(.candidates, hidden: false)

      case .challengeResultDidCancelled:
         break
//         pageNinjaViewModel.scrollToPage(.candidates)

      case let .presentReportDetailView(reportId):
         let input = ContenderDetailsSceneInput.winnerReportId(reportId)
         Asset.router?.route(
            .push,
            scene: \.challengeContenderDetail,
            payload: input,
            finishWork: scenario.events.loadChallengeByCurrentID
         )

      case let .setHeaderImage(image):
         if let image {
            headerViewModel.headerImage(image)
         }

      case let .presentChapter(chapter):
         switch chapter {
         case .details:
            challengeDetailsModel.viewModel.hidden(false)

//            pageNinjaViewModel
//               .getStateMachine(.details, type: ChallengeDetailsModel<Asset>.self)?
//               .setState(ChallengeDetailsBlockState.disableSendResult(true))
         case .winners:
            break
//            pageNinjaViewModel.scrollToPage(.winners)
         case .comments:
//            pageNinjaViewModel.scrollToPage(.comments)
            break
         case .report:
//            pageNinjaViewModel.scrollToPage(.winners)
            break
         }
      case .votingChallenge:
         break
//         pageNinjaViewModel.setPageHidden(.candidates, hidden: false)
//         pageNinjaViewModel
//            .getStateMachine(.candidates, type: ChallengeCandidatesModel<Asset>.self)?
//            .setState(.additionalCellButtonsEnabled(false))
      case .iAmOwner:
//         pageNinjaViewModel.setPageHidden(.candidates, hidden: false)
//         pageNinjaViewModel.scrollToPage(.candidates, animationDuration: 0)

//         pageNinjaViewModel
//            .getStateMachine(.details, type: ChallengeDetailsModel<Asset>.self)?
//            .setState(.disableSendResult(true))
//         pageNinjaViewModel
//            .getStateMachine(.candidates, type: ChallengeCandidatesModel<Asset>.self)?
//            .setState(.additionalCellButtonsEnabled(true))
         break
      case .enableWinners:
//         pageNinjaViewModel.setPageHidden(.winners, hidden: false)
         break
      case let .presentChallengeEdit(value):
         Asset.router?.route(
            .push,
            scene: \.challengeCreate,
            payload: ChallengeCreateInput.editChallenge(value),
            finishWork: scenario.events.didFinishChallengeOperation
         )
      case .activateEditButton:
         // TODO: - ACTIVATE
         reactionsBlock.editChallengeButton.hidden(false)
//         if vcModel?.navigationItem.rightBarButtonItems?.count ?? 0 < 2 {
//            let editButton = UIBarButtonItem(
//               image: Design.icon.tablerEditCircle,
//               style: .plain,
//               target: self,
//               action: #selector(editTapped)
//            )
//            vcModel?.navigationItem.rightBarButtonItems?.insert(editButton, at: 0)
//         }
      case let .presentShareView(url):
         presentSharing(link: url)
      case let .updatePayloadForPages(challenge):
         challengeDetailsModel.startWithPayload(challenge)
         headerViewModel.updateHeaderImages(photoUrls: challenge.photos, photoUrl: challenge.photo)
            .onSuccess {
               let index = self.headerViewModel.pagingImagesVM.pagingScrollModel.currentPage
               Asset.router?.route(
                  .presentModally(.automatic),
                  scene: \.imageViewer,
                  payload: ImageViewerInput.urls(challenge.photos ?? [], current: index)
               )
            }

         setState(.buttonLikePressed(alreadySelected: challenge.userLiked.unwrap))
         setState(.updateLikesAmount(challenge.likesAmount.unwrap))

         if challenge.isAvailable == true {
            buttonsPanel.sendButton.hidden(false)
            buttonsPanel.alignment(.fill)
         } else {
            buttonsPanel.sendButton.hidden(true)
            buttonsPanel.alignment(.leading)
         }

         if challenge.active == true,
            challenge.challengeCondition == .A,
            challenge.approvedReportsAmount < challenge.awardees,
            challenge.severalReports == true &&
            challenge.status == "Отчёт отправлен" || challenge.status == "Можно отправить отчёт"
         {
            buttonsPanel.sendButton.hidden(false)
            buttonsPanel.alignment(.fill)
         } else {
            buttonsPanel.sendButton.hidden(true)
            buttonsPanel.alignment(.leading)
         }

//         reactionsBlock.editChallengeButton.hidden(challenge.)
//         let isActive = challenge.active.unwrap
//         let challengeCondition = challenge.challengeCondition
//         statusLabel
//            .text(isActive ? Design.text.active : Design.text.completed)
//            .backColor(isActive ? Design.color.backgroundInfo : Design.color.backgroundSuccess)
//
//         switch challengeCondition {
//         case .A:
//            statusLabel.text(Design.text.active)
//         case .F:
//            statusLabel.text(Design.text.completed)
//         case .D, .W:
//            statusLabel.text(Design.text.deferred)
//         case .C:
//            statusLabel.text(Design.text.cancelled)
//         case .none:
//            break
//         }
      case .error:
         errorBlock.hidden(false)
         errorBlock.title.text(Design.text.notFoundEror)
         challengeDetailsModel.viewModel.hidden(true)

      case .challengeDeleted:
         Asset.router?.popToRoot()
         finishSucces()

      case let .buttonLikePressed(selected):
         reactionsBlock.likesBlock.setLiked(selected)

      case let .failedToReact(selected):
         reactionsBlock.likesBlock.setLiked(!selected)

      case let .updateLikesAmount(amount):
         reactionsBlock.likesBlock.label.text(String(amount))
      case .commentsCount:
         break

      case let .presentComments(challenge):
         Asset.router?.route(.presentModally(.automatic), scene: \.challengeComments, payload: challenge)

      case let .presentAllResults(data):
         Asset.router?.route(.push, scene: \.challengeResults, payload: data)
      case let .presentAllReactions(challenge):
         Asset.router?.route(.presentModally(.automatic), scene: \.challengeReactions, payload: ReactionsSceneInput.Challenge(challenge.id))
      }
   }
}

// MARK: - Header animation

extension ChallengeDetailsScene: NewHeaderAnimatedSceneProtocol {}
