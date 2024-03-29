//
//  ChallengeDetailsViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.10.2022.
//

import StackNinja

protocol DidUserTappableEvent: InitProtocol {
   var didTapUser: Void? { get set }
}

struct ChallengeDetailsVMEvents: DidUserTappableEvent {
   var didTapUser: Void?
}

extension ChallengeDetailsViewModel {
   func likePressed(_ value: Bool) {
      
   }
}

final class ChallengeDetailsViewModel<Design: DSP>:
   VStackModel,
   ActivityViewModelProtocol
{
   private(set) lazy var activityBlock = ActivityViewModel<Design>()

   var events = EventsStore()

   var scrollModel: ScrollStackedModelY { viewModelsContainer }

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
         .text(Design.text.prizeFund)
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

   private lazy var participantsCardInfoBlock = ChallengeChainCardInfoVM<Design> {
      $0.headerVM
         .image(Design.icon.gift.withTintColor(Design.color.iconBrand))
      $0.headerVM
         .text(Design.text.awardeesCount)
      $0.caption
         .text("0")
   }

   private lazy var userInfoCell = Design.model.profile.userPanel
      .shadow(Design.params.cellShadow)

   private lazy var descriptionLabel = LabelModel()
      .set(Design.state.label.descriptionRegular12)
      .numberOfLines(0)
      .text(Design.text.hereIsEmpty)

//   var buttonsPanel: ChallResultsButtonsPanel<Design> { models.down }

   private lazy var challengeInfo = DetailsInfoVM<Design>()

//   private lazy var prizeSizeCell = ChallengeDetailsInfoCell<Design>()
//      .setAll { icon, title, _, _ in
//         icon
//            .image(Design.icon.smallSpasibkaLogo)
//            .imageTintColor(Design.color.iconBrand)
//         title.text(Design.text.prizeFund)
//      }

//   private lazy var startDateCell = ChallengeDetailsInfoCell<Design>()
//      .setAll { icon, title, _, _ in
//         icon.image(Design.icon.tablerClock)
//         title.text(Design.text.dateOfStart)
//      }
//      .hidden(true)

//   private lazy var finishDateCell = ChallengeDetailsInfoCell<Design>()
//      .setAll { icon, title, _, _ in
//         icon.image(Design.icon.tablerClock)
//         title.text(Design.text.dateOfCompletion)
//      }
//      .hidden(true)

//   private lazy var prizePlacesCell = ChallengeDetailsInfoCell<Design>()
//      .setAll { icon, title, _, _ in
//         icon.image(Design.icon.tablerGift)
//         title.text(Design.text.awardeesCount)
//      }
//      .hidden(true)

   private lazy var viewModelsContainer = ScrollStackedModelY()
//      .safeAreaOffsetDisabled()
      .spacing(8)
      .bounce(true)
      .hideVerticalScrollIndicator()
      .padding(.init(top: 4, left: 16, bottom: 16, right: 16))
      .alwaysBounceVertical(true)
      .arrangedModels(
         titleDescriptionBlock,
         HStackModel(fundsCardInfoBlock, finishDateCardInfoBlock.hidden(true), participantsCardInfoBlock)
            .spacing(8),
         userInfoCell,
         Spacer(20),
         descriptionLabel
         //
//         challengeInfo,
//         startDateCell,
//         finishDateCell,
//         prizeSizeCell,
//         prizePlacesCell,
//         Spacer(16),
//         LabelModel()
//            .set(Design.state.label.regular12Secondary)
//            .text(Design.text.organizer)
//            .padding(.horizontalOffset(16))
      )

   required init() {
      super.init()
//      setAll { _, sendPanel in
//         sendPanel
//            .backColor(Design.color.background)
//      }
   }

   override func start() {
      super.start()

//      viewModelsContainer.stack
//         .safeAreaOffsetDisabled()

      arrangedModels(
            activityBlock,
            viewModelsContainer.hidden(true)
         )

//      ChallResultsButtonsPanel<Design>
//      buttonsPanel
//         .padding(.horizontalOffset(Design.params.commonSideOffset))

      activityState(.loading)
   }
}

extension ChallengeDetailsViewModel: Eventable {
   typealias Events = ChallengeDetailsVMEvents
}

enum ChallengeDetailsViewModelState {
   case presentChallenge(Challenge)
}

extension ChallengeDetailsViewModel: StateMachine {
   func setState(_ state: ChallengeDetailsViewModelState) {
      switch state {
      case let .presentChallenge(challenge):

         titleDescriptionBlock.models.main.text(challenge.name.unwrap)
         titleDescriptionBlock.models.down.text(Design.text.challenge)
         descriptionLabel.text(challenge.description.unwrap)

         activityState(.hidden)
         viewModelsContainer.hidden(false)

         challengeInfo.setup(.init(
            name: challenge.name,
            description: challenge.description,
            status: challenge.status
         ))

         fundsCardInfoBlock.caption
            .text(Design.text.pluralCurrencyWithValue(challenge.prizeSize, case: .genitive))

//         if let startDateStr = challenge.startAt?.dateFormatted(.dMMMyHHmm) {
//            startDateCell.models.right3
//               .text(startDateStr)
//         }
//         startDateCell.hidden(challenge.startAt == nil)

         if let endDateStr = challenge.endAt?.dateFormatted(.ddMMyyyy) {
            finishDateCardInfoBlock.caption
               .text(endDateStr)
         }
         finishDateCardInfoBlock.hidden(challenge.endAt == nil)

         participantsCardInfoBlock.caption
            .text(challenge.winnersCount.unwrap.toString + " / " + challenge.awardees.toString)
         participantsCardInfoBlock.hidden(challenge.winnersCount == nil)

         if challenge.fromOrganization == true {
            userInfoCell.models.right.fullName.text(challenge.organizationName.unwrap)
         } else {
            let creatorName = challenge.creatorName.unwrap
            let creatorSurname = challenge.creatorSurname.unwrap
            let creatorTgName = "@" + challenge.creatorTgName.unwrap
            userInfoCell.models.right.fullName.text(creatorName + " " + creatorSurname)
            userInfoCell.models.right.nickName.text(creatorTgName)
            if let creatorPhoto = challenge.creatorPhoto {
               userInfoCell.models.main.url(SpasibkaEndpoints.urlBase + creatorPhoto)
            }
            userInfoCell.view.startTapGestureRecognize()
            userInfoCell.view.on(\.didTap, self) {
               $0.send(\.didTapUser)
            }
         }
//
//         if let userLiked = challenge.userLiked {
//            if userLiked == true {
//               buttonsPanel.likeButton.setState(.selected)
//            } else {
//               buttonsPanel.likeButton.setState(.none)
//            }
//
//            let likesAmount = String(challenge.likesAmount ?? 0)
//            buttonsPanel.likeButton.models.right.text(likesAmount)
//         }

//         if challenge.isAvailable == true {
//            buttonsPanel.sendButton.hidden(false)
//            buttonsPanel.alignment(.fill)
//         } else {
//            buttonsPanel.sendButton.hidden(true)
//            buttonsPanel.alignment(.trailing)
//         }


//         if challenge.active == true,
//            challenge.challengeCondition == .A,
//            challenge.approvedReportsAmount < challenge.awardees,
//            challenge.severalReports == true &&
//            challenge.status == "Отчёт отправлен" || challenge.status == "Можно отправить отчёт"
//         {
//            buttonsPanel.sendButton.hidden(false)
//            buttonsPanel.alignment(.fill)
//         } else {
//            buttonsPanel.sendButton.hidden(true)
//            buttonsPanel.alignment(.trailing)
//         }
      }
   }
}

// import UIKit
//
// #Preview {
//   let mockChallenge = Challenge.makeMock()
//   let model = ChallengeDetailsModel<ProductionAsset>()
//   let viewModel = model.viewModel
//   model.setState(.presentChallenge(mockChallenge))
//   return PreviewWrapper(viewModel)
// }
