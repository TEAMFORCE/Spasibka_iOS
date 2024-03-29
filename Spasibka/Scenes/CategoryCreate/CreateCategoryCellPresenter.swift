//
//  CreateCategoryCellPresenter.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.08.2023.
//

import StackNinja

final class CreateCategoryCellPresenter<Design: DSP>: Eventable {
   struct Events: InitProtocol {
      var didCheckmarked: (isSelected: Bool, index: Int)?
   }

   var events = EventsStore()

   var presenter: CellPresenterWork<SelectWrapper<CategoryData>, CategoryCell<Design>> { .init { work in
      let item = work.in.item.value
      let index = work.in.indexPath.row
      let cell = CategoryCell<Design>()

      if item.depth.unwrap > 0 {
         cell.label.textColor(Design.color.textSecondary)
      }
      cell.label.text(item.name)
      cell.disclosureIcon.hidden(true)

      cell.checkMark.setState(work.in.item.isSelected)
      cell.checkMark.on(\.didSelected, self) {
         $0.send(\.didCheckmarked, (isSelected: $1, index: index))
      }
      cell.padding(.verticalOffset(8))
      cell.padLeft(item.depth.unwrap.cgFloat * 24)

      work.success(cell)
   }}
}
