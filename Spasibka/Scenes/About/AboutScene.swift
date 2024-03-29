//
//  AboutScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 29.12.2022.
//

import StackNinja
import UIKit

struct AboutSceneParams<Asset: ASP>: SceneParams {
   typealias Models = AboutSceneModelParams<Asset.Design>
   typealias InOut = AboutSceneInOutParams
}

struct AboutSceneModelParams<Design: DSP>: SceneModelParams {
   typealias VCModel = DefaultVCModel
   typealias MainViewModel = BrandDoubleStackVM<Design>
}

struct AboutSceneInOutParams: InOutParams {
   typealias Input = Void
   typealias Output = Void
}

//

final class AboutScene<Asset: ASP>: BaseParamsScene<AboutSceneParams<Asset>>, Scenarible {
   lazy var scenario = AboutScenario<Asset>(
      works: AboutWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: AboutScenarioEvents()
   )

   private lazy var locationBlock = AboutTitleBodyBlock<Design>().setAll {
      $0.text(Design.text.region)
      $1.text(Design.text.searchingInProgress)
   }
   
   private lazy var licenseEndLabel = AboutTitleBodyBlock<Design>().setAll {_,_ in }

   override func start() {
      vcModel?.title(Design.text.aboutTheApp)

      let deviceVersion = UIDevice.modelName
      let systemVersion = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
      let appVersion = Bundle.main.releaseVersionNumber.unwrap + "." + Bundle.main.buildVersionNumber.unwrap
      let domenName = Config.urlBase
      mainVM.bodyStack
         .alignment(.center)
         .spacing(12)
         .arrangedModels(
            Spacer(16),
            ImageViewModel()
               .size(.square(64))
               .image(Design.icon.smallSpasibkaLogo.insetted(6))
               .backColor(Design.color.backgroundBrand)
               .cornerCurve(.continuous)
               .cornerRadius(Design.params.cornerRadiusSmall),
            Spacer(16),
            AboutTitleBodyBlock<Design>().setAll {
               $0.text(Design.text.appVersion)
               $1.text(appVersion)
            },
            AboutTitleBodyBlock<Design>().setAll {
               $0.text(Design.text.OSVersion)
               $1.text(systemVersion)
            },
            AboutTitleBodyBlock<Design>().setAll {
               $0.text(Design.text.deviceModel)
               $1.text(deviceVersion)
            },
            AboutTitleBodyBlock<Design>().setAll {
               $0.text(Design.text.domain)
               $1.text(domenName)
            },
            locationBlock,
            Spacer(),
            licenseEndLabel,
            Spacer(32)
         )

      scenario.configureAndStart()
   }
}

enum AboutSceneState {
   case locationData(UserLocationData)
   case licenseEndData(String)
}

extension AboutScene: StateMachine {
   func setState(_ state: AboutSceneState) {
      switch state {
      case .locationData(let data):
         locationBlock.models.down.text(data.locationName)
      case .licenseEndData(let data):
         licenseEndLabel.models.main.text(Design.text.licenseIssuedBefore + data)
      }
   }
}

private final class AboutTitleBodyBlock<Design: DSP>: Stack<LabelModel>.D<LabelModel>.Ninja {
   required init() {
      super.init()

      setAll { title, body in
         title
            .set(Design.state.label.regular12)
            .textColor(Design.color.textSecondary)
            .numberOfLines(0)
            .alignment(.center)
         body
            .set(Design.state.label.regular12)
            .textColor(Design.color.text)
            .numberOfLines(0)
            .alignment(.center)
      }
      .spacing(4)
   }
}
