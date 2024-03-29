//
//  ChainDetailsViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.09.2023.
//

import StackNinja

final class ChainDetailsViewModel<Design: DSP>: VStackModel, ActivityViewModelProtocol {
   var events = EventsStore()

   private(set) lazy var activityBlock = ActivityViewModel<Design>()

   private(set) lazy var titleDescriptionBlock = M<LabelModel>.D<LabelModel>.R<LabelModel>.Ninja()
      .setAll { title, descript, about in
         title
            .set(Design.state.label.descriptionMedium20)
            .numberOfLines(0)
         descript
            .set(Design.state.label.descriptionRegular12)
         about
            .set(Design.state.label.descriptionMedium8)
      }
      .spacing(5)

   private lazy var fundsCardInfoBlock = ChallengeChainCardInfoVM<Design> {
      $0.headerVM
         .image(Design.icon.smallLogo.withTintColor(Design.color.iconBrand))
      $0.headerVM
         .text(Design.text.taskStatus)
      $0.caption
         .text("0")
   }

   private lazy var finishDateCardInfoBlock = ChallengeChainCardInfoVM<Design> {
      $0.headerVM
         .image(Design.icon.clock.withTintColor(Design.color.iconContrast))
      $0.headerVM
         .text(Design.text.finishDate)
      $0.caption
         .text("0")
   }

//   private lazy var participantsCardInfoBlock = ChallengeChainCardInfoVM<Design> {
//      $0.headerVM
//         .image(Design.icon.gift.withTintColor(Design.color.iconBrand))
//      $0.headerVM
//         .text(Design.text.awardeesCount)
//      $0.caption
//         .text("0")
//   }

   private lazy var userInfoCell = Design.model.profile.userPanel
      .shadow(Design.params.cellShadow)

   private lazy var descriptionLabel = LabelModel()
      .set(Design.state.label.descriptionRegular12)
      .numberOfLines(0)
      .text(Design.text.hereIsEmpty)

//   private lazy var progressBar = ProgressBarWithLabelVM<Design>()
//      .backColor(Design.color.background)
//      .cornerCurve(.continuous)
//      .cornerRadius(Design.params.cornerRadiusSmall)
//      .shadow(Design.params.cellShadow)
//      .padHorizontal(24)
//      .padVertical(16)

//   private lazy var chainInfoCell = DetailsInfoVM<Design>()
//
//   private lazy var startDateCell = ChallengeDetailsInfoCell<Design>()
//      .setAll { icon, title, _, _ in
//         icon.image(Design.icon.tablerClock)
//         title.text(Design.text.dateOfStart)
//      }
//
//   private lazy var finishDateCell = ChallengeDetailsInfoCell<Design>()
//      .setAll { icon, title, _, _ in
//         icon.image(Design.icon.tablerClock)
//         title.text(Design.text.dateOfCompletion)
//      }
//
   private(set) lazy var scrollModel = ScrollStackedModelY()
      .spacing(8)
      .bounce(true)
      .hideVerticalScrollIndicator()
      .padding(.init(top: 4, left: 16, bottom: 16, right: 16))
      .alwaysBounceVertical(true)
      .arrangedModels(
         titleDescriptionBlock,
         HStackModel(fundsCardInfoBlock, finishDateCardInfoBlock) // , participantsCardInfoBlock)
            .spacing(8),
         userInfoCell,
         Spacer(20),
         descriptionLabel
//         progressBar.hidden(true),
//         chainInfoCell,
//         startDateCell.hidden(true),
//         finishDateCell.hidden(true),
//         Spacer(16),
      )

   override func start() {
      super.start()

      arrangedModels(
         activityBlock,
         scrollModel.hidden(true)
      )
   }
}

extension ChainDetailsViewModel: Eventable {
   struct Events: DidUserTappableEvent {
      var didTapUser: Void?
   }
}

extension ChainDetailsViewModel: StateMachine {
   struct ModelState {
      let name: String?
      let description: String?

      let progressTotal: Int?
      let progressCurrent: Int?

      let startAt: String?
      let endAt: String?

      let fromOrganization: Bool?
      let organizationName: String?

      let creatorName: String?
      let creatorSurname: String?
      let creatorTgName: String?
      let creatorPhoto: String?
   }

   func setState(_ state: ModelState) {
      titleDescriptionBlock.models.main.text(state.name.unwrap)
      titleDescriptionBlock.models.down.text(Design.text.challengeChain)

      if let progressTotal = state.progressTotal, let progressCurrent = state.progressCurrent {
         //     let progressValue = progressCurrent.cgFloat / progressTotal.cgFloat
//         progressBar.bar.progressValue(progressValue)
//         progressBar.label.text("\(progressCurrent)/\(progressTotal)")
         fundsCardInfoBlock.caption.text("\(progressCurrent)/\(progressTotal) " + Design.text.done)
      }

      descriptionLabel.text(state.description.unwrap)

      activityBlock.setState(.hidden)
      scrollModel.hidden(false)

//      chainInfoCell.setup(.init(
//         name: state.name,
//         description: state.description,
//         status: nil
//      ))
//
//      if let startDateStr = state.startAt {
//         startDateCell.models.right3
//            .text(startDateStr)
//         startDateCell.hidden(false, isAnimated: true)
//      } else {
//         startDateCell.hidden(true)
//      }

      finishDateCardInfoBlock.caption
         .text(state.endAt.unwrap)

      if state.fromOrganization == true {
         userInfoCell.models.right.fullName.text(state.organizationName.unwrap)
      } else {
         let creatorName = state.creatorName.unwrap
         let creatorSurname = state.creatorSurname.unwrap
         let creatorTgName = state.creatorTgName.unwrap
         userInfoCell.models.right.fullName.text(creatorName + " " + creatorSurname)
         userInfoCell.models.right.nickName.text(creatorTgName)
         if let creatorPhoto = state.creatorPhoto {
            userInfoCell.models.main.url(SpasibkaEndpoints.urlBase + creatorPhoto)
         }
         userInfoCell.view.startTapGestureRecognize()
         userInfoCell.view.on(\.didTap, self) {
            $0.send(\.didTapUser)
         }
      }
   }
}
