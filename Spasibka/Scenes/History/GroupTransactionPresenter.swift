//
//  GroupTransactionPresenter.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 28.09.2023.
//

import StackNinja
import UIKit

final class GroupTransactionPresenters<Design: DesignProtocol>: Designable {
   var events: EventsStore = .init()

   var transactToHistoryCell: CellPresenterWork<TransactionByGroup, WrappedX<StackModel>> {
      CellPresenterWork { [weak self] work in
         
         let item = work.unsafeInput.item
         
         let icon = ImageViewModel()
            .contentMode(.scaleAspectFill)
            .cornerCurve(.continuous).cornerRadius(Grid.x36.value / 2)
            .size(.square(Grid.x36.value))
            .image(Design.icon.newAvatar)
         
         if let photo = item.userPhoto {
            icon.url(SpasibkaEndpoints.urlBase + photo)
         }

         var senderName = item.firstName.string + " " + item.surname.string
         if senderName.count == 1 {
            senderName = item.tgName.string
         }
         
         let infoLabel = LabelModel()
            .set(Design.state.label.labelRegular14)
            .text(senderName)
         
         let sentLabel = LabelModel()
            .set(Design.state.label.descriptionRegular12)
            .text(Design.text.sent)
         
         let sentModel = LabelIconModel<Design>()
            .setAll { title, icon in
               title
                  .text(item.ready.unwrap.toString)
               icon
                  .image(Design.icon.smallSpasibkaLogo)
            }
         
         let sentStack = StackModel()
            .axis(.horizontal)
            .alignment(.center)
            .distribution(.fill)
            .arrangedModels([
               sentLabel,
               Grid.xxx.spacer,
               sentModel,
            ])
         
         let recievedLabel = LabelModel()
            .set(Design.state.label.descriptionRegular12)
            .text(Design.text.received)
         
         let recievedModel = LabelIconModel<Design>()
            .setAll { title, icon in
               title.text(item.received.unwrap.toString)
               icon.image(Design.icon.smallSpasibkaLogo)
            }
         
         let recievedStack = StackModel()
            .axis(.horizontal)
            .alignment(.center)
            .distribution(.fill)
            .arrangedModels([
               recievedLabel,
               Grid.xxx.spacer,
               recievedModel,
            ])
         
         
         let subStack = StackModel()
               .axis(.vertical)
               .spacing(6)
               .arrangedModels([
                  infoLabel,
                  sentStack,
                  recievedStack
               ])
         
         let cellStack = WrappedX(
            StackModel()
               .padding(Design.params.cellContentPadding)
               .spacing(Grid.x12.value)
               .axis(.horizontal)
               .alignment(.top)
               .arrangedModels([
                  icon,
                  subStack
               ])
               .cornerCurve(.continuous)
               .cornerRadius(Design.params.cornerRadiusSmall)
               .backColor(Design.color.background)
               .shadow(Design.params.newCellShadow)
         )
         .padding(.init(top: 12, left: 16, bottom: 12, right: 16))

         work.success(result: cellStack)
      }
   }
}

final class LabelIconModel<Design: DSP>: Stack<LabelModel>.R<ImageViewModel>.Ninja, Designable {
   required init() {
      super.init()
      
      setAll {
         $0
            .set(Design.state.label.descriptionMedium12)
            .textColor(Design.color.textBrand)
         $1
            .size(.square(Grid.x16.value))
            .imageTintColor(Design.color.iconBrand)
      }
      spacing(4)
      backColor(Design.color.background)
      height(32)
   }
}
