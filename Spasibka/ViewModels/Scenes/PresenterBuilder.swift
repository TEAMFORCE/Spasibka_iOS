//
//  PresenterBuilder.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 27.12.2022.
//

import StackNinja

protocol PresenterModelBuilder: InitProtocol, Designable {
   //
   var loginOrganizationCell: CellPresenterWork<OrganizationAuth, WrappedX<StackModel>> { get }
   var changeOrganizationCell: CellPresenterWork<Organization, StackModel> { get }
   //
   var spacer: CellPresenterWork<SpacerItem, Spacer> { get }
}

struct PresenterBuilder<Design: DSP>: PresenterModelBuilder {
   //
   var loginOrganizationCell: CellPresenterWork<OrganizationAuth, WrappedX<StackModel>> {
      CellPresenterWork { work in
         let item = work.unsafeInput.item

         let icon = ImageViewModel()
            .contentMode(.scaleAspectFill)
            .image(Design.icon.newAvatar)
            .size(.square(Grid.x36.value))
            .cornerCurve(.continuous).cornerRadius(Grid.x36.value / 2)

         let orgName = LabelModel()
            .text(item.organizationName.unwrap)
            .set(Design.state.label.medium16)

         if let avatar = item.organizationPhoto {
            let url = SpasibkaEndpoints.convertToImageUrl(avatar)
            icon.image(Design.icon.anonAvatar)
            icon.url(url)
         } else {
            icon.image(Design.icon.anonAvatar)
            let colorScheme = OrganizationColorScheme(rawValue: item.organizationId) ?? .spasibka
            let brandColor = ColorToken.brandColorForOrganization(colorScheme)
            icon.imageTintColor(brandColor)
         }

         let cellStack = WrappedX(
            StackModel()
               .padding(Design.params.cellContentPadding)
               .spacing(Grid.x12.value)
               .axis(.horizontal)
               .alignment(.center)
               .arrangedModels([
                  icon,
                  orgName,
               ])
               .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
               .backColor(Design.color.backgroundInfoSecondary)
         )
         .padding(.init(top: 0, left: 0, bottom: 8, right: 0))

         work.success(result: cellStack)
      }
   }

   var changeOrganizationCell: CellPresenterWork<Organization, StackModel> { .init { work in
      let organization = work.unsafeInput

      let label = LabelModel()
         .text(organization.item.name ?? "")
         .textColor(Design.color.text)
      let icon = ImageViewModel()
         .contentMode(.scaleAspectFill)
         .image(Design.icon.anonAvatar)
         .size(.square(Grid.x36.value))
         .cornerCurve(.continuous)
         .cornerRadius(Grid.x36.value / 2)

      // TODO: - Сделать нормально
      let colorScheme = OrganizationColorScheme(rawValue: organization.item.id) ?? .spasibka
      icon.imageTintColor(ColorToken.brandColorForOrganization(colorScheme))
      //

      let cell = StackModel()
         .spacing(Grid.x12.value)
         .axis(.horizontal)
         .alignment(.center)
         .arrangedModels([
            icon,
            label,
            Spacer(),
         ])
         .padding(.init(top: 12, left: 16, bottom: 12, right: 16))

      work.success(cell)
   }}
}

extension PresenterBuilder {
   var spacer: CellPresenterWork<SpacerItem, Spacer> {
      SpacerPresenter.presenter
   }
}
