//
//  BenefitBasketVM.swift

//
//  Created by Aleksandr Solovyev on 24.01.2023.
//

import StackNinja

final class BenefitBasketVM<Design: DSP>: StackModel {
   lazy var eventer = BenefitBasketCellPresenter<Design>()

   lazy var benefitList = TableItemsModel()
      .backColor(Design.color.background)
      .presenters(
         eventer.presenter
//         SpacerPresenter.presenter
      )
      .setNeedsLayoutWhenContentChanged()
//      .separatorColor(Design.color.cellSeparatorColor)
//      .separatorStyle(.singleLine)

   override func start() {
      super.start()

      arrangedModels(benefitList)
   }
}

struct BenefitBasketCellEvent: InitProtocol {
   var deletePressed: Int?
   var countPlusPressed: Int?
   var countMinusPressed: Int?
   var checkMarkSelected: (Bool, index: Int)?
}

final class BenefitBasketCellPresenter<Design: DSP>: Eventable {
   typealias Events = BenefitBasketCellEvent
   var events: EventsStore = .init()

   var presenter: CellPresenterWork<CartItem, WrappedX<BenefitBasketCell<Design>>> { .init {
      let cell = BenefitBasketCell<Design>()
      let item = $0.unsafeInput.item
      let index = $0.unsafeInput.indexPath.row
      cell.setState(.item(item))

      cell.deleteButton.on(\.didTap, self) {
         $0.send(\.deletePressed, index)
      }
      cell.countPlusButton.on(\.didTap, self) {
         $0.send(\.countPlusPressed, index)
      }
      cell.countMinusButton.on(\.didTap, self) {
         $0.send(\.countMinusPressed, index)
      }
      cell.checkMark.on(\.didSelected, self) {
         $0.send(\.checkMarkSelected, ($1, index))
      }
      let res = WrappedX(
         cell
            .cornerCurve(.continuous)
            .cornerRadius(Design.params.cornerRadiusSmall)
            .backColor(Design.color.background)
            .shadow(Design.params.newCellShadow)
            .padding(Design.params.cellContentPadding)
      )
      .padding(.init(top: 8, left: 16, bottom: 8, right: 16))
      $0.success(res)
   } }
}
