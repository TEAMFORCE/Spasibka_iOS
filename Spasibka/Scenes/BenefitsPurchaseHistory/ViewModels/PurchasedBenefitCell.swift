//
//  PurchasedBenefitCell.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 05.02.2023.
//

import StackNinja
import UIKit

final class PurchasedBenefitCell<Design: DSP>:
   Stack<WrappedX<ImageViewModel>>
   .Down<LabelModel>
   .Down2<LabelModel>
   .Down3<LabelModel>
   .Down4<HStackModel>
   .Ninja
{
   var icon: ImageViewModel { models.main.subModel }
   var dateLabel: LabelModel { models.down }
   var title: LabelModel { models.down2 }
   var subtitle: LabelModel { models.down3 }
   var priceStatus: HStackModel { models.down4 }

   var priceButton = CurrencyButtonDT<Design>()
   var statusButton = ButtonModel()
      .height(40)
      .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusMini)
      .font(Design.font.semibold14)
      .textColor(Design.color.textSecondary)
      .backColor(Design.color.backgroundSecondary)
      .padding(.horizontalOffset(12))

   required init() {
      super.init()

      setAll { icon, dateLabel, title, subtitle, priceStatus in
         icon
            .addArrangedModel(Spacer())
            .subModel
            .size(.square(40))
            .cornerCurve(.continuous).cornerRadius(40 / 2)
            .contentMode(.scaleAspectFill)
            .image(Design.icon.tablerBriefcase.insetted(8).withTintColor(Design.color.iconBrand))
         dateLabel
            .set(Design.state.label.regular12Secondary)
         title
            .set(Design.state.label.semibold14)
         subtitle
            .set(Design.state.label.regular14)
            .textColor(Design.color.textSecondary)
         priceStatus
            .arrangedModels(priceButton, Spacer(), statusButton)
      }
      .spacing(12)
      .padding(.init(top: 22, left: 22, bottom: 22, right: 22))
      .backViewModel(
         StackModel()
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusBig)
            .backColor(Design.color.background)
            .shadow(Design.params.cellShadow),
         inset: .init(top: 6, left: 6, bottom: 6, right: 6)
      )
   }
}

extension PurchasedBenefitCell {
   static var presenter: CellPresenterWork<CartItem, PurchasedBenefitCell<Design>> { .init { work in
      let item = work.in.item
      let cell = PurchasedBenefitCell<Design>()

      var showcaseImage: String?
      if let image = item.presentingImages?.first(where: {
         $0.forShowcase == true
      }) {
         showcaseImage = image.link
      }

      cell.icon.url(showcaseImage)
      cell.dateLabel.text("#" + String(item.id) + " \(Design.text.processed): " + item.createdAt.unwrap.dateFullConverted)
      cell.title.text(item.name ?? "")
      cell.subtitle.text(item.description.unwrap)

      cell.priceButton.label
         .text(String(item.price.unwrap))

      if let statusCode = item.orderStatus, let status = OrderStatus(rawValue: statusCode) {
         let statusText = OrderStatusFactory<Design>.description(for: status)
         let statusColors = OrderStatusFactory<Design>.colors(for: status)

         cell.statusButton
            .backColor(statusColors.background)
            .title(statusText)
            .textColor(statusColors.text)
      } else {
         cell.statusButton.hidden(true)
      }

      work.success(cell)
   }}
}

enum OrderStatus: Int, CaseIterable {
   case movedFromCartToOrders = 1
   case acceptedWaiting = 5
   case acceptedByCustomer = 6
   case purchased = 7
   case readyForDelivery = 8
   case sentOrDelivered = 9
   case ready = 10
   case declined = 20
   case cancelled = 21
}

struct OrderStatusFactory<Design: DSP> {
   static func description(for orderStatus: OrderStatus) -> String {
      switch orderStatus {
      case .movedFromCartToOrders:
         return Design.text.ordered
      case .acceptedWaiting:
         return Design.text.acceptedWaiting
      case .acceptedByCustomer:
         return Design.text.acceptedByCustomer
      case .purchased:
         return Design.text.purchased
      case .readyForDelivery:
         return Design.text.readyForDelivery
      case .sentOrDelivered:
         return Design.text.sentOrDelivered
      case .ready:
         return Design.text.ready
      case .declined:
         return Design.text.declined
      case .cancelled:
         return Design.text.cancelled
      }
   }

   static func colors(for orderStatus: OrderStatus) -> (background: UIColor, text: UIColor) {
      switch orderStatus {
      case .movedFromCartToOrders:
         return (Design.color.backgroundInfoSecondary, Design.color.textInfo)
      case .acceptedWaiting:
         return (Design.color.backgroundWarningSecondary, Design.color.textWarning)
      case .acceptedByCustomer:
         return (Design.color.backgroundSuccessSecondary, Design.color.textSuccess)
      case .purchased:
         return (Design.color.backgroundInfoSecondary, Design.color.textInfo)
      case .readyForDelivery: 
         return (Design.color.backgroundSuccessSecondary, Design.color.textSuccess)
      case .sentOrDelivered:
         return (Design.color.backgroundSuccessSecondary, Design.color.textSuccess)
      case .ready:
         return (Design.color.backgroundInfoSecondary, Design.color.textInfo)
      case .declined:
         return (Design.color.backgroundErrorSecondary, Design.color.textError)
      case .cancelled:
         return (Design.color.backgroundSecondary, Design.color.textMidpoint)
      }
   }
}
