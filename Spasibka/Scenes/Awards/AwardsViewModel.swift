//
//  AwardsViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 11.12.2023.
//

import Foundation
import StackNinja

final class AwardsViewModel<Asset: ASP>: VStackModel, Assetable, Scenarible, Eventable {
   typealias Events = MainSubsceneEvents
   var events = EventsStore()

   private(set) lazy var scenario = AwardsViewModelScenario(
      works: AwardsViewModelWorks<Asset>(),
      stateDelegate: stateDelegate,
      events: .init(
         initialMode: .init(),
         didTapFilterAll: filterButtons.on(\.didTapFilterAll),
         didTapFilterWithIndex: filterButtons.on(\.didTapFilterWithIndex)
      )
   )
   private lazy var filterButtons = AwardsFilterButtons<Design>()
      .padHorizontal(16)
      .padBottom(16)

   private lazy var presenter = AwardsScrollCell<Design>
      .presenter(onDidSelectItemAtIndexPath: scenario.events.didTapAwardAtIndexPath)
   private lazy var tableModel = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(presenter)
      .footerModel(Spacer(96))
      .setNeedsLayoutWhenContentChanged()
      .headerModelFactory { _, section in
         LabelModel()
            .set(Design.state.label.semibold20)
            .textColor(Design.color.text)
            .text(section.title.unwrap)
            .wrappedX()
            .backColor(Design.color.background)
            .padding(.init(top: 12, left: 16, bottom: 8, right: 16))
      }
      .on(\.didScroll, self) { $0.send(\.didScroll, $1.velocity) }
      .on(\.willEndDragging, self) { $0.send(\.willEndDragging, $1.velocity) }

   override func start() {
      super.start()

      arrangedModels(
         filterButtons,
         tableModel,
         Spacer()
      )
   }

   func startWithMode(_ mode: AwardsMode) {
      scenario.configureAndStart()
      scenario.events.initialMode.sendAsyncEvent(mode)
   }
}

enum AwardsViewModelState {
   case initial

   case presentFilterButtons([String])
   case presentAwardSections([AwardsSection])
   case presentAwardDetails(Award)

   case error
}

extension AwardsViewModel: StateMachine {
   func setState(_ state: AwardsViewModelState) {
      switch state {
      case .initial:
         break
      case let .presentFilterButtons(filters):
         filterButtons.setFilterButtons(filters)
      case let .presentAwardSections(awardSections):
         tableModel.itemSections(awardSections.map { .init(title: $0.title, items: [$0.awards]) })
      case let .presentAwardDetails(award):
         Asset.router?.route(.presentModally(.automatic), scene: \.awardDetails, payload: award)
      case .error:
         break
      }
   }
}

final class AwardsScrollCell<Design: DSP>: WrappedX<ScrollStackedModelX> {
   override func start() {
      super.start()

      backColor(Design.color.background)
      subModel
         .spacing(16)
         .padding(.init(top: 20, left: 16 + 12, bottom: 28, right: 16 + 12))
      backViewModel(
         ViewModel()
            .backColor(Design.color.background)
            .cornerCurve(.continuous)
            .cornerRadius(Design.params.cornerRadiusBig)
            .shadow(Design.params.cellShadow),
         inset: .init(top: 8, left: 16, bottom: 16, right: -16)
      )
      maskToBounds(false)
      clipsToBound(false)
   }
}

extension AwardsScrollCell {
   static func presenter(onDidSelectItemAtIndexPath: Out<IndexPath>) -> CellPresenterWork<[Award], AwardsScrollCell<Design>> { .init { work in
      let items = work.in.item
      let indexPath = work.in.indexPath
      let cell = AwardsScrollCell<Design>()

      cell.subModel.arrangedModels(
         items.enumerated().map { index, award in
            let awardCell = AwardsCell<Design>()
            let target = award.toScore.unwrap
            let current = award.scored.unwrap
            let received = award.received.unwrap
            let text = received
               ? Design.text.awardReceived
               : current == target
               ? Design.text.getAward
               : "\(current)/\(target)"
            let textColor = received
               ? Design.color.textContrastSecondary
               : current == target
               ? Design.color.textBrand
               : Design.color.text
            if let url = award.coverFullUrlString {
               awardCell.icon
                  .indirectUrl(url)
            } else {
               let iconColor = received
                  ? Design.color.success
                  : current == target
                  ? Design.color.iconBrand
                  : Design.color.iconSecondary
               awardCell.icon
                  .imageTintColor(iconColor)
            }
            awardCell.caption
               .textColor(textColor)
               .text(text)
            awardCell.icon
               .setNeedsStoreModelInView()
            awardCell.view
               .startTapGestureRecognize()
               .on(\.didTap, onDidSelectItemAtIndexPath) {
                  $0.sendAsyncEvent(.init(row: index, section: indexPath.section))
               }
            awardCell.awardRewardBadge.label.text(award.reward.unwrap.toString)
            return awardCell
         }
      )
      work.success(cell)
   }}
}

final class AwardsCell<Design: DSP>: Stack<WrappedX<ImageViewModel>>.D<LabelModel>.Ninja {
   var icon: ImageViewModel { models.main.subModel }
   var caption: LabelModel { models.down }
   let awardRewardBadge = AwardRewardBadge()

   required init() {
      super.init()

      setAll { iconContainer, caption in
         iconContainer
            .cornerRadius(Design.params.cornerRadiusSmall)
            .cornerCurve(.continuous)
            .backColor(Design.color.backgroundSecondary)
            .shadow(Design.params.cellShadow)
         iconContainer.subModel
            .size(.square(70))
            .cornerRadius(Design.params.cornerRadiusSmall)
            .cornerCurve(.continuous)
            .contentMode(.scaleAspectFill)
            .image(Design.icon.tablerAward.insetted(8).withTintColor(Design.color.iconSecondary))
         caption
            .set(Design.state.label.regular12)
            .alignment(.center)
            .contentMode(.top)
            .numberOfLines(2)
            .textColor(Design.color.text)
      }
      spacing(8)
      addModel(
         awardRewardBadge.centeredX()
            .size(.square(24))
            .backColor(Design.color.background)
            .cornerRadius(24 / 2)
            .cornerCurve(.continuous)
            .shadow(Design.params.cellShadow)
            .padding(.outline(3))
      ) { anchors, view in
         anchors
            .centerX(view.rightAnchor, -6)
            .centerY(view.topAnchor, 6)
      }
   }

   final class AwardRewardBadge: StackNinja<SComboMR<LabelModel, ImageViewModel>>, Designable, ButtonTapAnimator {
      //
      var label: LabelModel { models.main }
      var currencyLogo: ImageViewModel { models.right }

      required init() {
         super.init()

         setAll {
            $0
               .set(Design.state.label.medium8)
               .text("0")
               .textColor(Design.color.text)
            $1
               .size(.square(8))
               .image(Design.icon.smallLogo, color: Design.color.iconBrand)
         }
         axis(.horizontal)
         alignment(.center)
      }
   }
}
