//
//  DigitalThanksScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 24.06.2022.
//

import Foundation
import StackNinja

// MARK: - DigitalThanksScene

final class DigitalThanksScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   BodyFooterStackModel,
   Asset,
   Void,
   Void
> {
   private lazy var enterButton = Design.button.default
      .title(Design.text.enterButton)
      .set(Design.state.button.inactive)

   // Debug
   private lazy var popup = BottomPopupPresenter()
   private lazy var popupTable = SimpleTableVM()
      .setNeedsLayoutWhenContentChanged()
   private lazy var debugLabel = LabelModel()
      .text("Debug mode")
      .padding(.horizontalOffset(16))
      .height(50)
   private lazy var prodLabel = LabelModel()
      .text("Production mode")
      .padding(.horizontalOffset(16))
      .height(50)

   private lazy var userAgreementVM = Stack<CheckMarkModel<Design>>.R<LabelModel>.Ninja()
      .setAll { _, label in
         label
            .numberOfLines(2)
            .set(Design.state.label.regular12)
            .textColor(Design.color.iconBrand)

         let infoText: NSMutableAttributedString = .init(string: "")
         let text = Design.text.agreementText
         let textPolicy = Design.text.agreementPolicy
         let textAgree = Design.text.agreementTermsOfUse

         infoText.append(Design.text.agreeWith.colored(Design.color.text))
         infoText.append(textPolicy.colored(Design.color.textBrand))
         infoText.append(Design.text.andConditions.colored(Design.color.text))
         infoText.append(textAgree.colored(Design.color.textBrand))

         label.attributedText(infoText)
         label.view.sizeToFit()
         label.view.makePartsClickable(substring1: textPolicy, substring2: textAgree)
      }
      .spacing(10)
      .alignment(.center)
      .setup {
         $0.models.right.view.on(\.didSelectRangeIndex) {
            switch $0 {
            case 0:
               Asset.router?.route(.push, scene: \.pdfViewer, payload: Config.privacyPolicyPayload)
            case 1:
               Asset.router?.route(.push, scene: \.pdfViewer, payload: Config.userAgreementPayload)
            default:
               break
            }
         }

         $0.models.main.on(\.didSelected, self) {
            if $1 {
               $0.enterButton.set(Design.state.button.default)
               Asset.service.userDefaultsStorage.saveValue(true, forKey: .isUserPrivacyApplied)
            } else {
               $0.enterButton.set(Design.state.button.inactive)
               Asset.service.userDefaultsStorage.saveValue(false, forKey: .isUserPrivacyApplied)
            }
         }
      }

   // MARK: - Start

   override func start() {
      //

      configure()

      enterButton
         .on(\.didTap) {
            Asset.router?.route(.push, scene: \.login, payload: nil)
         }

      userAgreementVM.models.main.setState(Asset.service.userDefaultsStorage.loadValue(forKey: .isUserPrivacyApplied).unwrap)
   }

   private func configure() {
      mainVM
         .backColor(Design.color.background)

      mainVM.bodyStack
         .set(Design.state.stack.default)
         .set(.alignment(.center))
         .arrangedModels([
            LoginLogo<Design>()
               .width(220)
               .height(64),
            Grid.xxx.spacer,
            ImageViewModel()
               .image(Design.icon.transactSuccess)
               .size(.square(280)),
         ])

      mainVM.footerStack
         .set(Design.state.stack.bottomPanel)
         .arrangedModels([
            Grid.x1.spacer,
            TitleSubtitleY<Design>()
               .padding(.top(Design.params.titleSubtitleOffset))
               .setMain {
                  $0
                     .text(Design.text.digitalThanks)
                     .padBottom(Grid.x8.value)
               } setDown: {
                  $0.text(Design.text.digitalThanksAbout)
               },
            Grid.x1.spacer,
            enterButton,
            userAgreementVM
               .minHeight(32),
         ])

      if Config.appConfig != .production {
         vcModel?.on(\.motionEnded, self) { slf, event in
            switch event {
            case .motionShake:
               slf.popupTable.models([
                  slf.debugLabel,
                  slf.prodLabel,
                  Spacer(64),
               ])
               slf.popup.setState(
                  .presentWithAutoHeight(
                     model: slf.popupTable,
                     onView: slf.vcModel?.view.superview
                  ))
            default:
               break
            }

            slf.popupTable.on(\.didSelectRow) {
               switch $0.row {
               case 0:
                  Config.setDebugMode(true)
               default:
                  Config.setDebugMode(false)
               }
               slf.popup.setState(.hide)
            }
         }
      }
   }
}
