//
//  CategoryCell.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.07.2023.
//

import StackNinja

//final class CategoryCellPresenter<Design: DSP>: Eventable {
//   struct Events: InitProtocol {
//      var didCheckmarked: Bool?
//   }
//
//   var events = EventsStore()
//
//   var presenter: CellPresenterWork<CategoryData, CategoryCell<Design>> { .init { work in
//      let item = work.in.item
//      let cell = CategoryCell<Design>()
//
//      cell.label.text(item.name)
//      if item.children?.isEmpty == true {
//         cell.disclosureIcon.hidden(true)
//      }
//
//      cell.checkMark.on(\.didSelected, self) {
//         $0.send(\.didCheckmarked, $1)
//      }
//      cell.padding(.verticalOffset(16))
//      cell.label.userInterractionEnabled(false)
//      work.success(cell)
//   }}
//}

final class CategoryCell<Design: DSP>: Stack<CheckMarkLabel<Design>>.R<ImageViewModel>.Ninja {
   var checkMark: CheckMarkModel<Design> { models.main.checkMark }
   var label: LabelModel { models.main.label }
   var disclosureIcon: ImageViewModel { models.right }

   required init() {
      super.init()

      setAll { _, disclosureIcon in
         disclosureIcon
            .size(.square(24))
            .image(Design.icon.tablerChevronRight, color: Design.color.iconSecondary)
      }
      backColor(Design.color.background)
      setNeedsStoreModelInView()
   }
}
