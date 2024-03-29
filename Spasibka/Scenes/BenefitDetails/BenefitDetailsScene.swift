//
//  BenefitDetailsScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 17.01.2023.
//

import StackNinja
import UIKit

final class BenefitDetailsScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   AnimatedHeaderNavbarBodyFooterStack<Asset>,
   Asset,
   (Int, Market),
   Void
>, Scenarible {
   //

   lazy var scenario = BenefitDetailsScenario(
      works: BenefitDetailsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: BenefitDetailsInputEvents(
         saveInput: on(\.input),
         addToBasket: Work.void,
         updateDetails: .init()
      )
   )

   // Default header image
   
   var headerHeightConstraint: NSLayoutConstraint?

   var headerBrightness = ColorBrightnessStyle.dark

   let headerTitle = Design.text.benefit

   private(set) lazy var headerViewModel = ChallengeChainHeaderVM<Design>(
      placeholder: Design.icon.challengeWinnerIllustrateFull,
      backColor: Design.color.backgroundBrand
   )
   .on(\.didImagePresented) { [weak self] style in
      DispatchQueue.concurentBackground.async {
         self?.setNavBarStyleForImage(style.image, backColor: style.backColor)
         DispatchQueue.main.async {
            //  self?.updateNavBarTintForHeaderImage()
         }
      }
   }
   .addModel(reactionsBlock) {
      $0
         .fitToTopRight($1, offset: 64, sideOffset: 16)
   }
   
   private lazy var usersButtonBlock = ChallengeChainUsersButtonBlock<Asset>()
   private lazy var reactionsBlock = BenefitReactionsBlock<Design> {
      $0.basketButton.on(\.didTap, self) {
         guard let market = $0.inputValue?.1 else { return }
         Asset.router?.route(
            .push,
            scene: \.benefitBasket,
            payload: market,
            finishWork: $0.scenario.events.updateDetails
         )
      }
   }

   private lazy var defaultHeaderImage = {
      let image = Design.icon.challengeWinnerIllustrateFull
      self.setNavBarStyleForImage(image, backColor: headerBackColor)
      self.updateNavBarTintForHeaderImage()
      return image
   }()


   private lazy var headerBackColor = Design.color.backgroundBrandSecondary

   private var benefit: Benefit?
   
   private lazy var toCartButton = ButtonSelfModable()
         .set(Design.state.button.default)
         .font(Design.font.medium16)
         .title(Design.text.addToCart)

   // View models


   private lazy var benefitDetails = BenefitDetailsViewModel<Design>()
      .backColor(Design.color.background)


   private lazy var sendButtonActivityIndicator = ActivityIndicator<Design>()

   override func start() {
      super.start()

      if vcModel?.isModal == false {
         vcModel?.navBarTranslucent(true)
      } else {
         mainVM.footerStack.hidden(true)
      }

      setState(.presentActivityIndicator)

      configure()
      scenario.configureAndStart()

      vcModel?.on(\.viewWillAppearByBackButton, self) {
         $0.toCartButton.setMode(\.inactive)
         $0.scenario.sendStartEvent()
         if $0.isHeaderPresented {
            $0.presentHeaderAll()
         } else {
            $0.hideHeaderAll()
         }
      }
      
      presentHeaderAll()
      updateNavBarTintForHeaderImage()
   }

   private func configure() {
      
      mainVM.navBar.menuButton.image(nil)
      
      mainVM.headerStack
         .arrangedModels([
            headerViewModel
         ])

      mainVM.bodyStack
         .backColor(Design.color.background)

      mainVM.footerStack
         .padding(.init(
            top: 0,
            left: 16,
            bottom: 16,
            right: 16
         ))
         .backColor(Design.color.background)


      benefitDetails.on(\.willEndDragging, self) {
         if $1.velocity <= 0, !$0.isHeaderPresented {
            $0.presentHeaderAll()
         } else if $1.velocity > 0, $0.isHeaderPresented {
            $0.hideHeaderAll()
         }
      }

      toCartButton
         .onModeChanged(\.normal) { [weak self] in
            $0
               .title(Design.text.addToCart)
               .set(Design.state.button.default)
               .enabled(true)
               .on(\.didTap, self) {
                  $0.scenario.events.addToBasket.doAsync()
               }
            self?.sendButtonActivityIndicator.view.removeFromSuperview()
         }
         .onModeChanged(\.selected) { [weak self] in
            $0
               .title(Design.text.inCartButton)
               .set(Design.state.button.selected)
               .enabled(true)
               .on(\.didTap, self) {
                  guard let market = $0.inputValue?.1 else { return }
                  Asset.router?.route(
                     .push,
                     scene: \.benefitBasket,
                     payload: market,
                     finishWork: $0.scenario.events.updateDetails
                  )
               }
            self?.sendButtonActivityIndicator.view.removeFromSuperview()
         }
         .onModeChanged(\.awaitng) { [weak self] in
            guard let self else { return }

            $0
               .title("")
               .set(Design.state.button.awaiting)
               .enabled(false)
               .addModel(self.sendButtonActivityIndicator) {
                  $0
                     .centerY($1.centerYAnchor)
                     .centerX($1.centerXAnchor)
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

enum BenefitDetailsState {
   case initial

   case presentActivityIndicator
   case hereIsEmpty

   case presentBenefit(Benefit)

   case sendButtonAwaiting
   case sendButtonSelected
   case sendButtonNormal

   case buttonLikePressed(alreadySelected: Bool)
   case failedToReact(alreadySelected: Bool)
   case updateLikesAmount(Int)

   case addToBasketError
}

extension BenefitDetailsScene: StateMachine {
   func setState(_ state: BenefitDetailsState) {
      switch state {
      case .initial:
         break

      case .presentActivityIndicator:
         mainVM.bodyStack
            .arrangedModels([
               Design.model.common.activityIndicatorSpaced,
            ])

      case let .presentBenefit(benefit):
         self.benefit = benefit

         mainVM.bodyStack
            .arrangedModels([
               benefitDetails.padding(.horizontalOffset(Design.params.commonSideOffset)),
            ])
         mainVM.footerStack
            .arrangedModels([
               toCartButton,
            ])
         benefitDetails.setState(.presentBenefit(benefit))

         if benefit.orderStatus == .inCart {
            toCartButton.setMode(\.selected)
         } else {
            toCartButton.setMode(\.normal)
         }
         
         guard
            let imageUrls = benefit.images?.compactMap(\.link),
            imageUrls.isEmpty == false
         else {
            headerViewModel.backImage(defaultHeaderImage)
            return
         }
         
         headerViewModel.updateHeaderImages(photoUrls: imageUrls, photoUrl: nil)
            .onSuccess {
               let index = self.headerViewModel.pagingImagesVM.pagingScrollModel.currentPage
               Asset.router?.route(
                  .presentModally(.automatic),
                  scene: \.imageViewer,
                  payload: ImageViewerInput.urls(imageUrls, current: index)
               )
            }

      case .sendButtonSelected:
         toCartButton.setMode(\.selected)
         
      case .sendButtonNormal:
         toCartButton.setMode(\.normal)
         
      case .sendButtonAwaiting:
         toCartButton.setMode(\.awaitng)
         
      case .hereIsEmpty:
         mainVM.bodyStack
            .arrangedModels([
               HereIsEmptySpacedBlock<Design>(),
            ])


      case let .buttonLikePressed(selected):
         if selected {
//            buttonsPanel.likeButton.setState(.none)
         } else {
//            buttonsPanel.likeButton.setState(.selected)
         }

      case let .failedToReact(selected):
         print("failed to like")
         setState(.buttonLikePressed(alreadySelected: !selected))

      case let .updateLikesAmount(amount):
//         buttonsPanel.likeButton.models.right.text(String(amount))
         break

      case .addToBasketError:
         print("failure")
         toCartButton.setMode(\.normal)
      }
   }
}

extension BenefitDetailsScene: NewHeaderAnimatedSceneProtocol {}
