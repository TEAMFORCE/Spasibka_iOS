//
//  ChangeOrganizationVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 19.11.2022.
//

import StackNinja
import UIKit

final class OrganizationCell<Design: DSP>: Stack<ImageViewModel>.R<TitleBodyY>.R2<Spacer>.R3<ButtonModel>.Ninja {
   private var icon: ImageViewModel { models.main }
   private var title: LabelModel { models.right.title }
   private var body: LabelModel { models.right.body }
   private var button: ButtonModel { models.right3 }
   private var backModel = ViewModel()
      .cornerRadius(Design.params.cornerRadius)
      .cornerCurve(.continuous)
      .backColor(Design.color.background)
      .shadow(Design.params.cellShadow)

   required init() {
      super.init()

      setAll { icon, titleBody, _, button in
         icon
            .size(.square(40))
            .cornerRadius(20)
            .backColor(Design.color.backgroundBrand)
         titleBody
            .padLeft(12)
            .spacing(4)
         titleBody.title
            .set(Design.state.label.regular12)
            .textColor(Design.color.textBrand)
         titleBody.body
            .set(Design.state.label.regular14)
            .textColor(Design.color.text)
         button
            .userInterractionEnabled(false)
            .size(.square(40))
      }
      alignment(.center)
      height(66+8)
      padding(.horizontalOffset(32))
      backViewModel(backModel, inset: .init(top: 4, left: 16, bottom: 4, right: 16))
      setNeedsStoreModelInView()
   }
}

extension OrganizationCell: StateMachine {
   struct Data {
      let iconUrl: String?
      let iconPlaceholder: UIImage?
      let title: String?
      let body: String
      let buttonIcon: UIImage?
      let buttonTintColor: UIColor?
      let backColor: UIColor
   }

   func setState(_ state: Data) {
      backModel.backColor(state.backColor)
      body.text(state.body)
      button.image(state.buttonIcon, color: state.buttonTintColor)
      icon.indirectUrl(state.iconUrl, placeHolder: state.iconPlaceholder)
      if let titleText = state.title {
         title.text(titleText)
      } else {
         title.hidden(true)
      }
   }
}

extension OrganizationCell {
   static var presenter: CellPresenterWork<Organization, OrganizationCell<Design>> { .init { work in
      let organization = work.in.item
      let cell = OrganizationCell<Design>()
      let buttonIcon = organization.isCurrent
         ? (organization.hasLink ? Design.icon.share : nil)
         : Design.icon.exchange
      cell.setState(.init(
         iconUrl: organization.photo,
         iconPlaceholder: Design.icon.anonAvatar,
         title: organization.isCurrent ? Design.text.currentOrganization : nil,
         body: organization.name,
         buttonIcon: buttonIcon,
         buttonTintColor: organization.isCurrent ? Design.color.iconBrand : Design.color.iconContrast,
         backColor: organization.isCurrent ? Design.color.backgroundBrandSecondary : Design.color.background
      ))

      work.success(cell)
   } }
}
