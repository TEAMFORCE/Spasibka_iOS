//
//  ChangeFondAccount.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.04.2023.
//

import Foundation
import StackNinja

final class ChangeFondAccountVM<Design: DSP>: StackModel, Designable {
   //
   var events = EventsStore()
   //
   private lazy var changeButton = Stack<LabelModel>.D<LabelModel>.R<ImageViewModel>.Ninja()
      .setAll { title, organization, icon in
         title
            .set(Design.state.label.regular12)
            .text("Баланс")
            .textColor(Design.color.textBrand)
         organization
            .set(Design.state.label.medium16)
            .padding(.top(8))
         icon
            .image(Design.icon.arrowDropDownLine)
            .imageTintColor(Design.color.iconBrand)
            .size(.square(32))
      }
      .padding(Design.params.cellContentPadding)
      .backColor(Design.color.backgroundBrandSecondary)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)

   private lazy var typeTable = TableItemsModel()
      .backColor(Design.color.background)
      .setNeedsLayoutWhenContentChanged()
      .presenters(typePresenters)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
      .borderWidth(1)
      .borderColor(Design.color.iconBrand)
      .hidden(true)

   override func start() {
      view.on(\.willMoveToSuperview, self) {
         $0.configure()
      }
   }

   private func configure() {
      arrangedModels(
         changeButton,
         Spacer(8),
         typeTable
      )

      changeButton.view.startTapGestureRecognize()
      changeButton.view.on(\.didTap, self) {
         $0.typeTable.hidden(!$0.typeTable.view.isHidden)
      }

      typeTable.on(\.didSelectItemAtIndex, self) {
         $0.send(\.didSelectOrganizationIndex, $1)
         $0.typeTable.hidden(!$0.typeTable.view.isHidden)
      }
   }

   private var typePresenters: CellPresenterWork<String, StackModel> { .init { work in
      let type = work.unsafeInput

      let label = LabelModel()
         .text(type.item)
         .textColor(Design.color.text)

      let cell = StackModel()
         .spacing(Grid.x12.value)
         .axis(.horizontal)
         .alignment(.center)
         .arrangedModels([
            label,
            Spacer(),
         ])
         .padding(.init(top: 12, left: 16, bottom: 12, right: 16))

      work.success(cell)
   }}
}

extension ChangeFondAccountVM: SetupProtocol {
   func setup(_ data: (currentType: String, orgs: [String])) {
      changeButton.models.down.text(data.currentType)
      print(data.orgs)
      typeTable.items(data.orgs)
   }
   func changeButton(_ currentType: String) {
      changeButton.models.down.text(currentType)
   }
   func getType() -> String {
      changeButton.models.down.view.text ?? ""
   }
}

extension ChangeFondAccountVM: Eventable {
   struct Events: InitProtocol {
      var didSelectOrganizationIndex: Int?
   }
}

