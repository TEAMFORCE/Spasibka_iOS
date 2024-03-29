//
//  Awards.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.12.2023.
//

import StackNinja

struct AwardsSceneParams<Asset: ASP>: SceneParams {
   struct Models: SceneModelParams {
      typealias VCModel = DefaultVCModel
      typealias MainViewModel = NavbarBodyStack<Asset, PresentPush>
   }

   struct InOut: InOutParams {
      typealias Input = Void
      typealias Output = Void
   }
}

//final class HistoryScene<Asset: ASP>: BaseParamsScene<HistorySceneParams<Asset>>,
//   Scenarible
//{
final class AwardsScene<Asset: ASP>: BaseParamsScene<AwardsSceneParams<Asset>>,
                                     Scenarible {
//final class AwardsScene<Asset: ASP>: VStackModel, Assetable, Scenarible, Eventable {
//   typealias Events = MainSceneEvents<UserData?>
//   var events = EventsStore()
   private(set) lazy var scenario = AwardsScenario(
      works: AwardsWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: AwardsEvents(
         didSegmentButtonPressed: segmentControl.on(\.didTapButtons)
      )
   )

   private lazy var segmentControl = SegmentControl<Button2Event>(
      buttons:
      SegmentButton<Design>()
         .title(Design.text.all1)
         .font(Design.font.regular14),
      SegmentButton<Design>()
         .title(Design.text.myAwards)
         .font(Design.font.regular14)
   )
   .cornerRadius(Design.params.cornerRadiusSmall)
   .cornerCurve(.continuous)
   .distribution(.fillEqually)
   .clipsToBound(true)
   .maskToBounds(true)

   private lazy var awardsScene = AwardsViewModel<Asset>()
//      .on(\.didScroll) { [weak self] in
////         self?.send(\.didScroll, $0)
//      }
//      .on(\.willEndDragging) { [weak self] in
////         self?.send(\.willEndDragging, $0)
//      }

   private lazy var myAwardsScene = AwardsViewModel<Asset>()
//      .on(\.didScroll) { [weak self] in
////         self?.send(\.didScroll, $0)
//      }
//      .on(\.willEndDragging) { [weak self] in
////         self?.send(\.willEndDragging, $0)
//      }

   private lazy var pagingViewModel = PagingScrollViewModel()
      .setStates(.setViewModels([
         awardsScene,
         myAwardsScene,
      ]))
      .on(\.didViewModelPresented, self) {
         $0.segmentControl.setSelectedButton($1.index)
      }

   override func start() {
      super.start()
      mainVM.navBar.titleLabel.text(Design.text.awards)
      mainVM.bodyStack
         .arrangedModels([
            WrappedX(segmentControl)
               .padHorizontal(16),
            Grid.x16.spacer,
            pagingViewModel
         ])
         .padding(.horizontalOffset(0))
      

      scenario.configureAndStart()
   }
}

enum AwardsState {
   case allAwards
   case myAwards
}

extension AwardsScene: StateMachine {
   func setState(_ state: AwardsState) {
      switch state {
      case .allAwards:
//         send(\.updateTitle, Design.text.awards)
         awardsScene.startWithMode(.normal)
         pagingViewModel.scrollToIndex(0)
      case .myAwards:
//         send(\.updateTitle, Design.text.myAwards)
         myAwardsScene.startWithMode(.receivedAwards)
         pagingViewModel.scrollToIndex(1)
      }
   }
}
