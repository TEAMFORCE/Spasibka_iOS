//
//  PrivacyPolicyScene.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 28.12.2022.
//

import StackNinja
import PDFKit

struct PrivacyPolicySceneParams<Asset: ASP>: SceneParams {
   typealias Models = PrivacyPolicySceneModelParams<Asset.Design>
   typealias InOut = PrivacyPolicySceneInOutParams
}

struct PrivacyPolicySceneModelParams<Design: DSP>: SceneModelParams {
   typealias VCModel = DefaultVCModel
   typealias MainViewModel = BrandDoubleStackVM<Design>
}

struct PrivacyPolicySceneInOutParams: InOutParams {
   typealias Input = (title: String, pdfName: String)
   typealias Output = Void
}

//

final class PrivacyPolicyScene<Asset: ASP>: BaseParamsScene<PrivacyPolicySceneParams<Asset>>, Scenarible {
   //
   lazy var scenario = PrivacyPolicyScenario<Asset>(
      works: PrivacyPolicyWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: PrivacyPolicyInputEvents(input: on(\.input))
   )
   //
   private lazy var pdfVM = PdfViewModel()
      .autoScales(true)
      .backColor(Design.color.background)

   override func start() {
      mainVM.bodyStack
         .padHorizontal(.zero)
         .addArrangedModel(pdfVM)

      scenario.configureAndStart()
   }
}

enum PrivacyPolicySceneState {
   case setTitle(String)
   case presentPdfDocument(PDFDocument)
}

extension PrivacyPolicyScene: StateMachine {
   func setState(_ state: PrivacyPolicySceneState) {
      switch state {
      case .setTitle(let title):
         vcModel?.title(title)
      case .presentPdfDocument(let document):
         pdfVM.pdfDocument(document)
      }
   }
}
