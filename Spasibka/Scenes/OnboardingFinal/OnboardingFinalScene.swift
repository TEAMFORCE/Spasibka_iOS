//
//  OnboardingFinalScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.06.2023.
//

import StackNinja
import UIKit

final class OnboardingFinalScene<Asset: ASP>: BaseSceneModel<
   DefaultVCModel,
   BrandDoubleStackVM<Asset.Design>,
   Asset,
   (name: String, sharingKey: String), // shared key
   Void
> {
   private lazy var sharePopup = ShareCommunityPopup<Design>()
   private lazy var bottomPopupPresenter = BottomPopupPresenter()

   override func start() {
      guard let inputValue else { return }

      vcModel?.title(Design.text.congrats)

      mainVM.backColor(Design.color.background)
      mainVM.bodyStack
         .padBottom(32)
         .arrangedModels(
            Spacer(48.aspectedByHeight),
            ImageViewModel()
               .maxWidth(300)
               .maxHeight(300)
               .image(Design.icon.onboardSuccessIllustrate)
               .contentMode(.scaleAspectFit),
            Spacer(24.aspectedByHeight),
            Design.label.bold32
               .textColor(Design.color.textBrand)
               .alignment(.center)
               .text(Design.text.congrats)
               .centeredX(),
            Spacer(16),
            Design.label.medium20
               .text(Design.text.siteConfigComplete)
               .numberOfLines(2)
               .alignment(.center)
               .centeredX(),
            Spacer(),
            Design.button.default
               .title(Design.text.goToMainScreen)
               .setNeedsStoreModelInView()
               .on(\.didTap) {
                  Asset.router?.route(.presentInitial, scene: \.mainMenu)
                  Asset.router?.route(.presentInitial, scene: \.tabBar)
               },
            Spacer(16),
            Design.button.brandSecondary
               .title(Design.text.inviteMembersToCommunity)
               .setNeedsStoreModelInView()
               .on(\.didTap, self) { slf in
                  slf.sharePopup.setState((orgName: inputValue.name, sharingKey: inputValue.sharingKey))
                  slf.bottomPopupPresenter
                     .setState(.presentWithAutoHeight(model: slf.sharePopup, onView: slf.vcModel?.superview))
                  slf.sharePopup.closeButtonEvent
                     .onSuccess { [weak self] in
                        self?.bottomPopupPresenter.setState(.hide)
                     }
               },
            Spacer(16)
         )
   }
}

final class ShareCommunityPopup<Design: DSP>: Stack<LabelModel>
   .D<TitleTextFieldButtonVM<Design>>
   .D2<TitleTextFieldButtonVM<Design>>
   .D3<ButtonModel>.Ninja
{
   var closeButtonEvent: VoidWork { models.down3.on(\.didTap) }

   required init() {
      super.init()

      setAll { title, block1, block2, button in
         title
            .set(Design.state.label.medium20)
            .alignment(.center)
            .numberOfLines(2)

         block1
            .setStates(
               .title(Design.text.invitationCode),
               .textFieldUserInterractionEnabled(false),
               .buttonImage(Design.icon.share)
            )
            .hidden(true)

         block2
            .setStates(
               .title(Design.text.invitationLink),
               .textFieldUserInterractionEnabled(false),
               .buttonImage(Design.icon.share)
            )

         button
            .set(Design.state.button.default)
            .title(Design.text.closeButton)
      }

      backColor(Design.color.background)
      padding(.init(top: 24, left: 16, bottom: 24, right: 16))
      spacing(16)
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadiusBig)
   }
}

extension ShareCommunityPopup: StateMachine {
   func setState(_ state: (orgName: String, sharingKey: String)) {
      models.main.text(Design.text.communityCreated + "\n" + state.orgName)

      if
         let inviteString = state.sharingKey
         .components(separatedBy: "invite=")
         .last
      {
         models.down
            .setStates(.textFieldText(inviteString))
            .didTap.onSuccess { _ in
               UIPasteboard.general.string = inviteString
            }
      } else {
         models.down.hidden(true)
      }

      models.down2
         .setStates(.textFieldText(state.sharingKey))
         .didTap.onSuccess { _ in
            UIPasteboard.general.string = state.sharingKey
         }
   }
}
