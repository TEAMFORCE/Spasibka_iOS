//
//  ChallengeNewCell.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 06.09.2023.
//

import StackNinja
import UIKit

extension ChallengeChainCell: StateMachine {
   struct ModelState {
      let title: String
      let authorName: String
      let imageUrl: String?
      let progressTotal: Int?
      let progressCurrent: Int?
      let isLiked: Bool
      let likes: Int
   }

   func setState(_ state: ModelState) {
      backImage.indirectUrl(state.imageUrl)

      titleModel.text(state.title)
      authorModel.text(state.authorName)

      if state.isLiked {
         likeBlock.models.main.image(Design.icon.redHeart, color: Design.color.iconInvert)
      } else {
         likeBlock.models.main.image(Design.icon.heart, color: Design.color.iconInvert)
      }

      likeBlock.models.down.text("\(state.likes)")

      if let progressTotal = state.progressTotal, let progressCurrent = state.progressCurrent, progressTotal != 0 {
         let progressValue = progressCurrent.cgFloat / progressTotal.cgFloat
         progressVM.bar.progressValue(progressValue)
         progressVM.label.text("\(progressCurrent)/\(progressTotal)")
         progressVM.hidden(false)
      }
   }
}

final class ChallengeChainCell<Design: DSP>: VStackModel {
   private lazy var backImage = ImageViewModel()
      .backColor(Design.color.backgroundBrandSecondary)
      .contentMode(.scaleAspectFill)
      //  .image(Design.icon.challengeWinnerIllustrate)
      .cornerRadius(Design.params.cornerRadiusBig)
      .cornerCurve(.continuous)
      .addModel(
         ViewModel()
            .backColor(Design.color.constantBlack)
            .alpha(0.33)
      ) {
         $0.fitToView($1)
      }

   private lazy var titleModel = LabelModel()
      .set(Design.state.label.descriptionMedium16)
      .textColor(Design.color.text)
      .numberOfLines(2)

   private lazy var authorModel = LabelModel()
      .set(Design.state.label.descriptionRegular14)
      .textColor(Design.color.text)
      .numberOfLines(2)
      .padBottom(16)

   private lazy var progressVM = ProgressBarWithLabelVM<Design>()
      .padBottom(16)
      .hidden(true)

   private lazy var likeBlock = M<ImageViewModel>.D<LabelModel>.Ninja()
      .setAll {
         $0
            .image(Design.icon.heart, color: Design.color.constantWhite)
            .size(.square(24))
         $1
            .text("\(Int.random(in: 0 ... 1000))")
            .alignment(.center)
            .set(Design.state.label.descriptionMedium10)
            .textColor(Design.color.textInvert)
      }
      .spacing(3)
      .backColor(Design.color.constantBlack.withAlphaComponent(0.25))
      .padding(.outline(4))
      .cornerCurve(.continuous)
      .cornerRadius(6)


   override func start() {
      super.start()

      let padding = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

      addModel(
         Wrapped3Y(titleModel, authorModel, progressVM)
            .padVertical(16)
            .padHorizontal(32)
            .backColor(Design.color.background.withAlphaComponent(0.75))
      ) {
         $0.fitToBottom($1)
      }
      backViewModel(
         backImage.wrappedY(),
         inset: padding
      )
      addModel(likeBlock) { anchors, superview in
         anchors
            .top(superview.topAnchor, 24)
            .right(superview.rightAnchor, -32)
      }
      height(394.aspected)

      setNeedsStoreModelInView()
   }
}

final class ChallengeNewCell<Design: DSP>: VStackModel {
   private lazy var coverBlock = ChallengeNewCellCoverBlock<Design>()
   private lazy var infoBlock = ChallengeNewCellInfoBlock<Design>()
   private(set) lazy var likeBlock = ReactionBlockModel<Design>.likes

   private lazy var progressVM = ProgressBarWithLabelVM<Design>()
      .padBottom(12)
      .hidden(true)

   override func start() {
      super.start()

      let padding = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)

      addModel(
         Wrapped3Y(coverBlock, infoBlock, progressVM)
            .cornerRadius(Design.params.cornerRadiusBig)
            .cornerCurve(.continuous)
            .clipsToBound(true)
      ) {
         $0.fitToViewInsetted($1, padding)
      }
      backViewModel(
         ViewModel()
            .cornerRadius(Design.params.cornerRadiusBig)
            .cornerCurve(.continuous)
            .maskToBounds(false)
            .backColor(Design.color.background)
            .shadow(Design.params.panelShadow),
         inset: padding
      )
      addModel(likeBlock) { anchors, superview in
         anchors
            .top(superview.topAnchor, 36)
            .right(superview.rightAnchor, -32)
      }
      setNeedsStoreModelInView()
   }
}

enum ChallengeNewCellStatus {
   case active
   case completed
   case upcoming
   case unknown
}

extension ChallengeNewCell: StateMachine {
   typealias Status = ChallengeNewCellStatus

   struct ModelState {
      let title: String
      let authorName: String
      let imageUrl: String?
      let isLocked: Bool
      let updateDate: String
      let infoTitle1: String
      let infoSubtitle1: String
      let infoTitle2: String
      let infoSubtitle2: String
      let infoTitle3: String
      let infoSubtitle3: String
      let status: Status
      let progressTotal: Int?
      let progressCurrent: Int?
      let isLiked: Bool
      let likes: Int
   }

   func setState(_ state: ModelState) {
      coverBlock.setState(.init(
         title: state.title,
         authorName: state.authorName,
         imageUrl: state.imageUrl,
         isLocked: state.isLocked
      ))
      infoBlock.setState(.init(
         updateDate: state.updateDate,
         title1: state.infoTitle1,
         subtitle1: state.infoSubtitle1,
         title2: state.infoTitle2,
         subtitle2: state.infoSubtitle2,
         title3: state.infoTitle3,
         subtitle3: state.infoSubtitle3
      ))

      likeBlock.setLiked(state.isLiked)
      likeBlock.label.text("\(state.likes)")

      if let progressTotal = state.progressTotal, let progressCurrent = state.progressCurrent, progressTotal != 0 {
         let progressValue = progressCurrent.cgFloat / progressTotal.cgFloat
         progressVM.bar.progressValue(progressValue)
         progressVM.label.text("\(progressCurrent)/\(progressTotal)")
         progressVM.hidden(false)
      }
   }
}

// MARK: - ChallengeNewCellCoverBlock

final class ChallengeNewCellCoverBlock<Design: DSP>: VStackModel {
   private lazy var lockedChallengeBlock = IconTitleX()
      .setAll { icon, title in
         icon
            .image(Design.icon.lockOutline, color: Design.color.iconInvert)
            .size(.square(24))
         title
            .set(Design.state.label.medium12)
            .textColor(Design.color.textInvert)
            .text(Design.text.challengeIsUnavailable)
      }
      .spacing(16)

   private lazy var challengInfoBlock = TitleBodyY()
      .setAll { title, body in
         title
            .set(Design.state.label.descriptionMedium20)
            .textColor(Design.color.textInvert)
         body
            .set(Design.state.label.regular14)
            .textColor(Design.color.textInvert)
      }
      .spacing(8)

   private lazy var backImage = ImageViewModel()
      .backColor(Design.color.backgroundBrandSecondary)
      .contentMode(.scaleAspectFit)
      //  .image(Design.icon.challengeWinnerIllustrate)
      .addModel(
         ViewModel()
            .backColor(Design.color.constantBlack)
            .alpha(0.33)
      ) {
         $0.fitToView($1)
      }

   override func start() {
      super.start()

      arrangedModels(
         lockedChallengeBlock.centeredX(),
         Spacer(),
         challengInfoBlock
      )
      padding(.init(top: 24, left: 16, bottom: 16, right: 16))
      backViewModel(backImage.wrappedX())
      height(223.aspectedByHeight > 223 ? 223 : 223.aspectedByHeight)
   }
}

extension ChallengeNewCellCoverBlock: StateMachine {
   struct ModelState {
      let title: String
      let authorName: String
      let imageUrl: String?
      let isLocked: Bool
   }

   func setState(_ state: ModelState) {
      lockedChallengeBlock.hidden(!state.isLocked)
      challengInfoBlock.title.text(state.title)
      challengInfoBlock.body
         .text("\(Design.text.from.lowercased()) \(state.authorName)")
         .hidden(state.authorName.isEmpty)
      if let imageUrl = state.imageUrl {
         presentActivityModel(Design.model.common.activityIndicator)
         backImage.indirectUrl(imageUrl) { [weak self] model, _ in
            model?.contentMode(.scaleAspectFill)
            self?.hideActivityModel()
         }
      }
   }
}
