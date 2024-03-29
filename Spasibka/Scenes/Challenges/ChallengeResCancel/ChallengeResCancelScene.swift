//
//  ChallengeResCancelScene.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 17.10.2022.
//

import StackNinja

final class ChallengeResCancelScene<Asset: AssetProtocol>: BaseSceneModel<
   DefaultVCModel,
   ModalDoubleStackModel<Asset>,
   Asset,
   Int,
   Void
>, Scenarible {
//
   private let works = ChallengeResCancelWorks<Asset>()

   lazy var scenario = ChallengeResCancelScenario<Asset>(
      works: works,
      stateDelegate: stateDelegate,
      events: ChallengeResCancelEvents(
         saveInput: on(\.input),
         commentInputChanged: inputView.on(\.didEditingChanged),
         sendReject: sendButton.on(\.didTap)
      )
   )

   private lazy var inputView = Design.model.transact.reasonInputTextView
      .placeholder(Design.text.comment)
      .minHeight(166)

   private lazy var sendButton = Design.model.transact.sendButton

   override func start() {
      super.start()

      mainVM.title
         .text(Design.text.rejectApplication)

      mainVM.bodyStack
         .spacing(Grid.x16.value)
         .arrangedModels([
            inputView,
            Spacer(),
            Spacer(),
         ])
      mainVM.footerStack
         .arrangedModels([
            Grid.x16.spacer,
            sendButton,
         ])

      mainVM.closeButton
         .on(\.didTap, self) {
            $0.vcModel?.dismiss(animated: true)
            $0.finishCanceled()
         }

      scenario.configureAndStart()
   }
}

enum ChallengeResCancelSceneState {
   case initial

   case sendingEnabled
   case sendingDisabled

   case popScene
   case resultSent
   case finish
}

extension ChallengeResCancelScene: StateMachine {
   func setState(_ state: ChallengeResCancelSceneState) {
      switch state {
      case .initial:
         break
      case .sendingEnabled:
         sendButton.set(Design.state.button.default)
      case .sendingDisabled:
         sendButton.set(Design.state.button.inactive)
      case .popScene:
         vcModel?.dismiss(animated: true)
      case .resultSent:
         finishSucces()
      case .finish:
         vcModel?.dismiss(animated: true)
         finishSucces()
      }
   }
}
