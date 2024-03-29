//
//  ChallengeChainsViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 22.01.2024.
//

import Foundation
import StackNinja

final class ChallengeChainsViewModel<Asset: ASP>: ViewModel, Assetable, Scenarible {
   private(set) lazy var scenario = ChallengeChainsPreviewScenario<Asset>(
      works: NewChallengeChainWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: .init(
         presentAllChallenges: .init(),
         didSelectCollectionItemAtIndex: collectionModel.on(\.didSelectItemAtIndex)
      )
   )

   private lazy var collectionModel = CollectionViewModel(layouts:
      CollectionSectionsLayoutFactory.build(
         // TODO: - Разобраться с размерами
         groupSize: .init(widthDimension: .fractionalWidth(4), heightDimension: .estimated(1)),
         itemSize: .init(widthDimension: .estimated(1), heightDimension: .estimated(1)),
         itemSpacing: .fixed(11),
         contentInsets: .init(
            top: 0,
            leading: Design.params.commonSideOffset,
            bottom: 0,
            trailing: Design.params.commonSideOffset
         ),
         isHorizontal: true
      )
   )
   .presenters(ChallengeChainPreviewCellPresenter<Design>())
   .backColor(Design.color.background)

   private lazy var activityBlock = ActivityIndicator<Design>()

   override func start() {
      super.start()

      addModel(
         collectionModel
      )

      setState(.loading)

      scenario.configureAndStart()
   }
}

enum ChallengeChainsCollectionState {
   case presentChallenges([ChallengeGroup])
   case presentChallenge(ChallengeGroup)
   case loading
   case success
   case error
   case hereIsEmpty
}

extension ChallengeChainsViewModel: StateMachine {
   func setState(_ state: ChallengeChainsCollectionState) {
      switch state {
      case let .presentChallenges(challenges):
         if challenges.isEmpty {
            setState(.hereIsEmpty)
            return
         } else {
            setState(.success)
         }

         collectionModel.sections(
            [CollectionSection(items: challenges)],
            animated: true
         )
      case .success:
         hideActivityModel()
      case .loading:
         presentActivityModel(activityBlock)
      case .error:
         presentActivityModel(SystemErrorBlockVM<Design>())
      case .hereIsEmpty:
         presentActivityModel(HereIsEmpty<Design>())
      case .presentChallenge(let challengeGroup):
         Asset.router?.route(
            .push,
            scene: \.chainDetails,
            payload: .byChain(challengeGroup, chapter: .details)
         )
      }
   }
}

final class ChallengeChainPreviewCellPresenter<Design: DSP>: CollectionCellPresenter {
   func viewModel(for item: ChallengeGroup, indexPath _: IndexPath) -> UIViewModel {
      let cell = ChallengeChainPreviewCell<Design>()

      cell.backImage.indirectUrl(SpasibkaEndpoints.tryConvertToImageUrl(item.photos?.first))
      cell.titleLabel.text(item.name.unwrap)
      cell.descriptionLabel.text(item.author.unwrap)

      return cell
   }
}

final class ChallengeChainPreviewCell<Design: DSP>: VStackModel {
   private(set) lazy var backImage = ImageViewModel()
      .contentMode(.scaleAspectFill)

   private(set) lazy var titleLabel = LabelModel()
      .set(Design.state.label.regular9)
      .textColor(Design.color.text)

   private(set) lazy var descriptionLabel = LabelModel()
      .set(Design.state.label.medium10)
      .textColor(Design.color.text)

   override func start() {
      super.start()

      setNeedsStoreModelInView()

      arrangedModels(
         Spacer(118),
         Wrapped2Y(titleLabel, descriptionLabel)
            .padding(.init(top: 10, left: 9, bottom: 10, right: 9))
            .backColor(Design.color.background.withAlphaComponent(0.75))
      )
      backViewModel(backImage)
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadiusBig)
      clipsToBound(true)
      maskToBounds(true)
      size(.init(width: 140, height: 170))
      backColor(Design.color.iconMidpoint)
   }
}
