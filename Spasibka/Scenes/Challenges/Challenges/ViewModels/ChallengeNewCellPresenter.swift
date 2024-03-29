//
//  ChallengeNewCellPresenter.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 06.09.2023.
//

import StackNinja

final class ChallengeNewCellPresenter<Design: DSP>: Designable, Eventable {
   struct Events: InitProtocol {
      var didLikeTapped: Int?
   }

   var events: EventsStore = .init()

   var presenter: CellPresenterWork<Challenge, ChallengeNewCell<Design>> { .init { work in
      let index = work.in.indexPath.row
      let item = work.in.item
      let cell = ChallengeNewCell<Design>()

      let status: ChallengeNewCell<Design>.Status
      switch item.challengeCondition {
      case .A:
         status = .active
      case .F:
         status = .completed
      case .D, .W:
         status = .upcoming
      case .C:
         status = .completed
      case .none:
         status = .active
      }
      var authorName = item.creatorName.unwrap + " " + item.creatorSurname.unwrap
      if authorName.count < 2 {
         authorName = item.creatorNickname.unwrap
      }
      cell.setState(.init(
         title: item.name.unwrap.trimmingCharacters(in: .whitespacesAndNewlines),
         authorName: authorName,
         imageUrl: SpasibkaEndpoints.tryConvertToImageUrl(item.photo ?? item.photos?.first),
         isLocked: status == .completed,
         updateDate: item.updatedAt.unwrap.dateFormatted(.ddMMyyyy).unwrap,
         infoTitle1: item.fund.toString,
         infoSubtitle1: Design.text.reward,
         infoTitle2: item.winnersCount.unwrap.toString,
         infoSubtitle2: Design.text.winnersCount,
         infoTitle3: item.awardees.toString,
         infoSubtitle3: Design.text.awardeesCount,
         status: status,
         progressTotal: nil,
         progressCurrent: nil,
         isLiked: item.userLiked.unwrap,
         likes: item.likesAmount.unwrap
      ))
      cell.likeBlock.button.on(\.didTap, self) {
         $0.send(\.didLikeTapped, index)
      }

      work.success(cell)
   }}
}
