//
//  ChainDetailsScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 09.10.2022.
//

import StackNinja
import UIKit

enum ChainDetailsInput {
   case byChain(ChallengeGroup, chapter: ChainDetailsPageKey = .details)
   case byId(Int, chapter: ChainDetailsPageKey = .details)
}

struct ChainDetailsPageEvents: ScrollEventsProtocol {
   var willEndDragging: (velocity: CGFloat, offset: CGFloat)?
   var didScroll: (velocity: CGFloat, offset: CGFloat)?

   var updateChainDetails: ChallengeGroup?
}

enum ChainDetailsPageKey {
   case details
   case challenges
   case participants
}

final class ChainDetailsScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   AnimatedHeaderNavbarBodyFooterStack<Asset>,
   Asset,
   ChainDetailsInput,
   Void
> {
   //
   private(set) lazy var scenario = ChainDetailsScenario(
      works: ChainDetailsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: ChainDetailsInputEvents(
         payload: on(\.input),
         updateChainDetails: chainDetailsModel.on(\.updateChainDetails)
      )
   )

   // Default header image

   var headerBrightness = ColorBrightnessStyle.dark

   var headerHeightConstraint: NSLayoutConstraint?

   // Header

   private(set) lazy var headerViewModel = ChallengeChainHeaderVM<Design>(
      placeholder: Design.icon.challengeWinnerIllustrateFull,
      backColor: Design.color.iconBrand
   )
   .on(\.didImagePresented) { [weak self] style in
      DispatchQueue.concurentBackground.async {
         self?.setNavBarStyleForImage(style.image, backColor: style.backColor)
         DispatchQueue.main.async {
            //  self?.updateNavBarTintForHeaderImage()
         }
      }
   }
   .addModel(usersButtonBlock) {
      $0
         .left($1.leftAnchor, 16)
         .top($1.topAnchor, 64)
         .bottom($1.bottomAnchor, -42)
   }
//   .addModel(reactionsBlock) {
//      $0
//         .fitToTopRight($1, offset: 64, sideOffset: 16)
//   }

   private lazy var usersButtonBlock = ChallengeChainUsersButtonBlock<Asset>()
   private lazy var reactionsBlock = ChallengeChainReactionsBlock<Design> {
      $0.shareButton.on(\.didTap, self) {
         $0.hideHeaderAll()
      }
   }

   // Body

   private lazy var chainDetailsModel = ChainDetailsModel<Asset>()

   // Footer

   private lazy var footerButton = Design.button.default
      .font(Design.font.descriptionMedium12)
      .title(Design.text.chainSteps)

   // other

   private lazy var darkLoader = DarkLoaderVM<Design>()

   override func start() {
      super.start()

      presentHeaderAll()

      configure()
      // configureShareButton()
      bindPageEvents()

      vcModel?.on(\.viewWillAppear, self) {
         $0.setNavBarInvisible()
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

   private func configureShareButton() {
      let shareButton = UIBarButtonItem(
         image: Design.icon.arrowDropUpLine,
         style: .plain,
         target: self,
         action: #selector(shareTapped)
      )

      vcModel?.navigationItem.rightBarButtonItems = [shareButton]
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

   private func configure() {
      mainVM.headerStack
         .arrangedModels([
            headerViewModel
         ])

      mainVM.navBar
         .titleLabel.text(Design.text.challengeChain)

      mainVM.bodyStack
         .arrangedModels(
            chainDetailsModel.viewModel
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

      scenario.configureAndStart()
   }

   @objc func editTapped() {
      //    scenario.events.editButtonTapped.sendAsyncEvent()
   }

   @objc func shareTapped() {
      //  scenario.events.shareButtonTapped.sendAsyncEvent()
   }

   func bindPageEvents() {
      chainDetailsModel.on(\.willEndDragging, self) {
         if $1.velocity <= 0, !$0.isHeaderPresented {
            $0.presentHeaderAll()
         } else if $1.velocity > 0, $0.isHeaderPresented {
            $0.hideHeaderAll()
         }
      }
   }
}

enum ChainDetailsState {
   case initial

   case updateChainDetails(ChallengeGroup)
   case updatePayload(ChallengeGroup)
}

extension ChainDetailsScene: StateMachine {
   func setState(_ state: ChainDetailsState) {
      switch state {
      case .initial:
         break
      case let .updateChainDetails(details):

         usersButtonBlock.button.on(\.didTap) {
            Asset.router?.route(
               .push,
               scene: \.chainParticipantsScene,
               payload: details
            )
         }

         headerViewModel.updateHeaderImages(photoUrls: details.photos)
            .onSuccess {
               Asset.router?.route(.presentModally(.automatic), scene: \.imageViewer, payload: ImageViewerInput.url($0))
            }

         chainDetailsModel.startWithGenericPayload(details)

         footerButton.hidden(false)
         footerButton.on(\.didTap) {
            Asset.router?.route(
               .push, // presentModally(.pageSheet),
               scene: \.challengeChainSteps,
               payload: details
            )
         }

      // TODO: - Сделать общим для всех
//         switch details.currentState {
//         case .A:
//            statusLabel
//               .text(Design.text.active)
//               .backColor(Design.color.backgroundSuccess)
//         case .F:
//            statusLabel
//               .text(Design.text.completed)
//               .backColor(Design.color.backgroundInfo)
//         case .D, .W:
//            statusLabel
//               .text(Design.text.deferred)
//               .backColor(Design.color.backgroundWarning)
//         case .C:
//            statusLabel
//               .text(Design.text.cancelled)
//               .backColor(Design.color.iconMidpoint)
//         case .none:
//            break
//         }
      case let .updatePayload(payload):
         chainDetailsModel.startWithGenericPayload(payload)
      }
   }
}

// MARK: - Header animation

extension ChainDetailsScene: NewHeaderAnimatedSceneProtocol {}
