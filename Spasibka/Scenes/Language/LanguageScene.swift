//
//  LanguageScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 15.11.2023.
//

import StackNinja
import UIKit

struct LanguageSceneParams<Asset: ASP>: SceneParams {
   typealias Models = LanguageSceneModelParams<Asset.Design>
   typealias InOut = LanguageSceneInOutParams
}

struct LanguageSceneModelParams<Design: DSP>: SceneModelParams {
   typealias VCModel = DefaultVCModel
   typealias MainViewModel = BrandDoubleStackVM<Design>
}

struct LanguageSceneInOutParams: InOutParams {
   typealias Input = Void
   typealias Output = Void
}

final class LanguageScene<Asset: ASP>: BaseParamsScene<LanguageSceneParams<Asset>>, Scenarible {
   lazy var scenario = LanguageScenario<Asset>(
      works: LanguageWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: LanguageScenarioEvents(
         setEnglish: engLanguage.view.startTapGestureRecognize().on(\.didTap),
         setRussian: rusLanguage.view.startTapGestureRecognize().on(\.didTap),
         changeLanguage: .init()
      )
   )
   
   let engLanguage = WrappedY(
            IconTitleX()
               .setAll { icon, title in
                  icon
                     .image(Design.icon.usaFlag)
                  title
                     .textColor(Design.color.text)
                     .text(Design.text.englishLanguage)
               }
               .spacing(8)
               .padding(Design.params.cellContentPadding)
               .lefted()
         )
         .padding(Design.params.cellContentPadding)
         .backColor(Design.color.background)
         .shadow(Design.params.cellShadow)
         .height(68)
         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
   
   let rusLanguage = WrappedY(
            IconTitleX()
               .setAll { icon, title in
                  icon
                     .image(Design.icon.russiaFlag)
                  title
                     .textColor(Design.color.text)
                     .text(Design.text.russianLanguage)
               }
               .spacing(8)
               .padding(Design.params.cellContentPadding)
               .lefted()
         )
         .padding(Design.params.cellContentPadding)
         .backColor(Design.color.background)
         .shadow(Design.params.cellShadow)
         .height(68)
         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
   
   override func start() {
      vcModel?.title(Design.text.language)

      mainVM.bodyStack
         .spacing(12)
         .arrangedModels(
            engLanguage,
            rusLanguage,
            Spacer(),
            Spacer(32)
         )

      scenario.configureAndStart()
   }
}

enum LanguageSceneState {
   case showAlert(AppLanguages)
}

enum AppLanguages: String {
   case ru
   case en
}

extension LanguageScene: StateMachine {
   func setState(_ state: LanguageSceneState) {
      switch state {
      case .showAlert(let lang):
         var message = Design.text.changeLanguageAlert
         switch lang {
         case .en:
            message += Design.text.englishLanguage + "?"
         case .ru:
            message += Design.text.russianLanguage + "?"
         }
         let dialogMessage = UIAlertController(title: nil,
                                               message: message,
                                               preferredStyle: .alert)

         let yes = UIAlertAction(title: Design.text.yesLowercase, style: .default, handler: { [weak self] _ in
            print("Yes button tapped")
            self?.scenario.events.changeLanguage.sendAsyncEvent(lang)
         })

         let no = UIAlertAction(title: Design.text.noLowercase, style: .cancel) { _ in
            print("No button tapped")
         }

         dialogMessage.addAction(yes)
         dialogMessage.addAction(no)

         UIApplication.shared.windows.first?.rootViewController?.present(dialogMessage, animated: true, completion: nil)
      }
   }
}


