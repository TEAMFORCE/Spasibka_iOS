//
//  EventsCellPresenter.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 30.06.2023.
//

import StackNinja
import UIKit

final class EventsCellPresenter<Design: DesignProtocol>: Designable, Eventable {
   struct Events: InitProtocol {
      var didSelect: Int?
      var didTapLike: Int?
      var didTapMessage: Int?
      var didTapLink: URL?
      var didTapBirthdayButton: Int?
   }

   var events: EventsStore = .init()
   var userName: String = ""

   var presenter: PresenterProtocol { CellPresenterWork<FeedEvent, EventsCell<Design>>() { [weak self] work in
      guard let self = self else { return }

      let event = work.unsafeInput.item
      let index = work.unsafeInput.indexPath.row

      let cell = EventsCell<Design>()
      var title = ""

      let iconUrl = SpasibkaEndpoints.tryConvertToImageUrl(event.icon)
      var iconPlacaholder = Design.icon.avatarPlaceholder
      if let selector = event.selector {
         switch selector {
         case "T":
            title = Design.text.gratitude
         case "Q":
            iconPlacaholder = Design.icon.medal.insetted(6).withTintColor(Design.color.iconBrand)
            title = Design.text.challenge
         case "R":
            title = Design.text.challenge
         case "P":
            title = Design.text.purchaseUppercase
         case "B":
            title = Design.text.birthday
            iconPlacaholder = Design.icon.tablerGiftBrand.insetted(6)
            cell.hideReactionButtons()
            cell.showBirthdayButton()
         default:
            break
         }
      }
      cell.setState(.data(
         .init(
            imageUrl: iconUrl,
            imagePlaceholder: iconPlacaholder,
            dateText: self.makeDateLabelText(feed: event),
            title: title,
            text: event.text.unwrap,
            userLiked: event.userLiked.unwrap,
            likesAmount: event.likesAmount.unwrap,
            commentsAmount: event.commentsAmount.unwrap,
            tags: (event.tags ?? []).map { FeedTag(id: $0.tagId, name: $0.name)
            },
            selector: event.selector.unwrap,
            textIcon: event.textIcon
         )))

      cell.didTapLinkEvent
         .onSuccess(self) {
            $0.send(\.didTapLink, $1)
         }

      cell.didTapMessageButtonWork
         .onSuccess(self) {
            $0.send(\.didTapMessage, index)
         }

      cell.didTapLikeButtonWork
         .onSuccess(self) { [cell] in
            cell.setState(.liked(!event.userLiked.unwrap))
            cell.setState(.likeProcessing)
            $0.send(\.didTapLike, index)
         }
      
      cell.didTapBirthdayButtonWork
         .onSuccess(self) {
            $0.send(\.didTapBirthdayButton, event.id)
         }
      
      cell
         .padding(.init(top: 18, left: 28, bottom: 18, right: 28))
         .backViewModel(
            ViewModel {
               $0
                  .backColor(Design.color.background)
                  .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
                  .shadow(Design.params.newCellShadow)
            }, inset: .init(top: 8, left: 16, bottom: 8, right: 16)
         )
      work.success(result: cell)
   }}
}

private extension EventsCellPresenter {
   func makeDateLabelText(feed: FeedEvent) -> String {
//      let endDateText = feed.endAt?.dateConverted(inputFormat: .yyyyMMddTHHmmssZZZZZ, outputFormat: .dMMMy)
//      var fullFormat = feed.time?.dateAgoConverted(inputFormat: .yyyyMMddTHHmmssSSSSSSZ, unitsStyle: .full)
//      let birthdayFormat = feed.time?.dateAgoConverted(inputFormat: .yyyyMMddTHHmmssZZZZZ, unitsStyle: .full)
//      if fullFormat == nil && birthdayFormat != nil {
//         fullFormat = birthdayFormat
//      }
//      var dateText = fullFormat.unwrap + (endDateText != nil ? " • " + endDateText.unwrap : "")
//
//      if let date = feed.time?.dateConvertedToDate {
//         print(date)
//         if !Calendar.current.isDateInToday(date), !Calendar.current.isDateInYesterday(date) {
//            dateText = feed.time?.dateConvertedDDMMYY ?? "Hello"
//         }
//      }
      if let dateText = feed.time?.dateConverted(inputFormat: .yyyyMMddTHHmmssSSSSSSZ, outputFormat: .ddMMyyyy) {
         var text = dateText
         if let date = feed.time?.dateConvertedToDate {
            if Calendar.current.isDateInToday(date) {
               text = Design.text.today
            } else if Calendar.current.isDateInYesterday(date) {
               text = Design.text.yesterday
            }
            if let time = feed.time?.dateConverted(inputFormat: .yyyyMMddTHHmmssSSSSSSZ, outputFormat: .hhMM) {
               if feed.selector != "B" {
                  text += Design.text.inLowercase + time
               }
            }
         }
//         dateLabel.text(text)
         return text
      }
      return ""

//      return dateText
   }
}
