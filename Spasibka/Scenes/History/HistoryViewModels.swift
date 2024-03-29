//
//  HistoryViewModels.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 17.08.2022.
//

import Foundation
import StackNinja
import UIKit

struct HistoryViewModels<Design: DesignProtocol>: Designable {
   let backColor = UIColor(red: 0.542, green: 0.542, blue: 0.542, alpha: 0)
   lazy var tableModel = TableItemsModel()
      .backColor(Design.color.background)
      .headerParams(labelState: Design.state.label.labelRegularContrastColor14, backColor: backColor /*Design.color.background*/)
      .footerModel(Spacer(96))
      .setNeedsLayoutWhenContentChanged()

   lazy var filterButtons = SlidingManyButtons<Button3Event>(buttons:
      SecondaryButtonDT<Design>()
         .title(Design.text.allHistory)
         .font(Design.font.labelRegular14),
      SecondaryButtonDT<Design>()
         .title(Design.text.received)
         .font(Design.font.labelRegular14),
      SecondaryButtonDT<Design>()
         .title(Design.text.sent)
         .font(Design.font.labelRegular14)
   )
      .disableScroll()
   
   lazy var groupFilter = CheckMarkLabel<Design>()
      .setStates(
         .text(Design.text.groupByUser)
      )

   lazy var presenter = HistoryPresenters<Design>()
   lazy var groupTransactPresenter = GroupTransactionPresenters<Design>()
}
