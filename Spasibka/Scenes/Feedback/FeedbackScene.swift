//
//  FeedbackScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 03.08.2023.
//

import StackNinja
import UIKit

struct FeedbackSceneParams<Asset: ASP>: SceneParams {
   typealias Models = FeedbackSceneModelParams<Asset.Design>
   typealias InOut = FeedbackSceneInOutParams
}

struct FeedbackSceneModelParams<Design: DSP>: SceneModelParams {
   typealias VCModel = DefaultVCModel
   typealias MainViewModel = BrandDoubleStackVM<Design>
}

struct FeedbackSceneInOutParams: InOutParams {
   typealias Input = Void
   typealias Output = Void
}

final class FeedbackScene<Asset: ASP>: BaseParamsScene<FeedbackSceneParams<Asset>> {

   private lazy var imageModel = ImageViewModel()
      .maxWidth(300.aspectedByHeight)
      .maxHeight(300.aspectedByHeight)
      .contentMode(.scaleAspectFit)
      .image(Design.icon.smartPeopleIllustrate)
      .imageTintColor(Design.color.iconBrand)
   
   private let mainLabel = Design.label.medium20
      .alignment(.center)
      .numberOfLines(0)
      .text(Design.text.feedbackMainText)
   
   private lazy var mailLabel = IconTitleX()
      .setAll { icon, title in
         icon
            .image(Design.icon.tablerMailOpened)
         title
            .textColor(Design.color.text)
            .text(Design.text.emailForFeedback)
      }
      .spacing(16)
      .padding(Design.params.cellContentPadding)
      .lefted()
   
   private lazy var telegramLabel = IconTitleX()
      .setAll { icon, title in
         icon
            .image(Design.icon.tablerBrandTelegram)
         title
            .textColor(Design.color.text)
            .text(Design.text.tgForFeedback)
      }
      .spacing(16)
      .padding(Design.params.cellContentPadding)
      .lefted()
   
   override func start() {
      vcModel?.title(Design.text.feedback)
      
      mainVM.bodyStack
         .padHorizontal(0)
         .arrangedModels([
            Spacer(64),
            imageModel.centeredX(),
            Spacer(32),
            StackModel()
               .padHorizontal(16)
               .arrangedModels(
                  mainLabel,
                  StackModel()
                     .alignment(.leading)
                     .arrangedModels(
                        Spacer(32),
                        mailLabel,
                        telegramLabel
                     )
                     .centeredX(),
                  Spacer()
               ),
         ])
      
      mailLabel.view.startTapGestureRecognize().on(\.didTap) {
         let email = Design.text.emailForFeedback
         if let url = URL(string: "mailto:\(email)") {
           if #available(iOS 10.0, *) {
             UIApplication.shared.open(url)
           } else {
             UIApplication.shared.openURL(url)
           }
         }
      }
      
      telegramLabel.view.startTapGestureRecognize().on(\.didTap) {
         let tlgLink =  "https://t.me/exampleTelegram"
         let appURL = URL(string: tlgLink)!
         if UIApplication.shared.canOpenURL(appURL) {
             if #available(iOS 10.0, *) {
                 UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
             }
             else {
                 UIApplication.shared.openURL(appURL)
             }
         }
      }
   }
}
