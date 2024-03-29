//
//  ChallengeChainCellPresenter.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 10.09.2023.
//

import StackNinja

extension ChallengeNewCellStatus {
   init(withChallCondition: ChallengeCondition?) {
      switch withChallCondition {
      case .A:
         self = .active
      case .F:
         self = .completed
      case .D, .W:
         self = .upcoming
      case .C:
         self = .completed
      case .none:
         self = .unknown
      }
   }
}

struct ChallengeChainCellPresenter<Design: DSP>: Designable {
   static var presenter: CellPresenterWork<ChallengeGroup, ChallengeChainCell<Design>> { .init { work in
      let item = work.in.item
      let cell = ChallengeChainCell<Design>()

      let status = ChallengeNewCellStatus(withChallCondition: item.currentState)

      cell.setState(.init(
         title: item.name.unwrap,
         authorName: item.author.unwrap,
         imageUrl: SpasibkaEndpoints.tryConvertToImageUrl(item.photos?.first),
//         isLocked: status == .completed,
//         updateDate: item.updatedAt.unwrap.dateFormatted(.ddMMyyyy).unwrap,
//
//         infoTitle1: item.contendersTotal.unwrap.toString,
//         infoSubtitle1: Design.text.participants2,
//         infoTitle2: item.commentsTotal.unwrap.toString,
//         infoSubtitle2: Design.text.comments,
//         infoTitle3: item.tasksTotal.unwrap.toString,
//         infoSubtitle3: Design.text.tasksTotal,
//
//         status: status,
         progressTotal: item.tasksTotal,
         progressCurrent: item.tasksFinished,
         isLiked: false,
         likes: 0
      ))

      work.success(cell)
   }}
}
