//
//  ChallengesViewModels.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 06.10.2022.
//

import Foundation
import StackNinja

final class ChallengesViewModel<Design: DSP>: StackModel, Designable, Eventable {
   struct Events: InitProtocol {
      var didSelectChallenge: Int?
      var didLikePressedAtIndex: Int?
   }

   var events: EventsStore = .init()

   private lazy var presenter = ChallengeNewCellPresenter<Design>()
      .on(\.didLikeTapped, self) { $0.send(\.didLikePressedAtIndex, $1) }

   lazy var challengesTable = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         presenter.presenter
      )
      .footerModel(Spacer(96))
      .setNeedsLayoutWhenContentChanged()

   override func start() {
      super.start()

      arrangedModels([
         challengesTable,
         Spacer()
      ])

      challengesTable
         .on(\.didSelectItemAtIndex, self) {
            $0.send(\.didSelectChallenge, $1)
         }
   }
}

enum ChallengesViewModelState {
   case presentChallenges([Challenge])
}

extension ChallengesViewModel: StateMachine {
   func setState(_ state: ChallengesViewModelState) {
      switch state {
      case .presentChallenges(let challenges):
         challengesTable.items(challenges)
      }
   }
}
