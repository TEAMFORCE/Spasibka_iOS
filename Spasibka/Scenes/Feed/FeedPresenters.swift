//
//  FeedPresenters.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 20.09.2022.
//

import StackNinja
import UIKit

protocol FeedCellReactionProtocol: Eventable where Events == FeedUserActionEvents {
   func presenter() -> PresenterProtocol
}

final class FeedPresenters<Design: DesignProtocol>: Designable, FeedCellReactionProtocol {
   typealias Events = FeedUserActionEvents

   var events: EventsStore = .init()
   var userName: String = ""

   func presenter() -> PresenterProtocol {
      presenterWork
   }

   private var presenterWork: CellPresenterWork<Feed, WrappedX<StackModel>> {
      CellPresenterWork { [weak self] work in

         guard let self = self else { return }

         let feed = work.unsafeInput.item
         let index = work.unsafeInput.indexPath.row

         let dateLabel = FeedPresenters.makeInfoDateLabel(feed: feed)

         let messageButton = ReactionButton<Design>()
            .setAll {
               $0.image(Design.icon.messageCloud)
               $1.text(String(feed.commentsAmount))
            }

         let likeButton = ReactionButton<Design>()
            .setAll {
               $0.image(Design.icon.like)
               $1.text(String(feed.likesAmount))
            }

         likeButton.view.startTapGestureRecognize(cancelTouch: true)

         likeButton.view.on(\.didTap, self) {
            let body = PressLikeRequest.Body(
               likeKind: 1,
               transactionId: feed.transaction?.id,
               challengeId: feed.challenge?.id,
               challengeReportId: feed.winner?.id
            )
            let request = PressLikeRequest(
               token: "",
               body: body,
               index: index
            )
            $0.send(\.reactionPressed, request)

            likeButton.setState(.selected)
         }

         let reactionsBlock = StackModel()
            .axis(.horizontal)
            .alignment(.leading)
            .distribution(.fill)
            .spacing(4)
            .arrangedModels([
               messageButton,
               likeButton,
               Grid.xxx.spacer
            ])

         if let transaction = feed.transaction {

            let senderId = transaction.senderId
            let recipientId = transaction.recipientId
            let sender = FeedPresenters.getDisplayNameForSender(transaction: feed.transaction) //"@" + transaction.senderTgName.unwrap
            let recipient = FeedPresenters.getDisplayNameForRecipient(transaction: feed.transaction) //"@" + transaction.recipientTgName.unwrap

            let type = FeedTransactType.make(feed: feed, currentUserName: self.userName)

            let infoLabel = FeedPresenters.makeInfoLabel(feed: feed, type: type, eventType: EventType.transaction)

            let icon = self.makeIcon(feed: feed, type: EventType.transaction)

            infoLabel.view.on(\.didSelect) {
               switch $0 {
               case sender:
                  self.send(\.didSelect, senderId ?? -1)
               case recipient:
                  self.send(\.didSelect, recipientId ?? -1)
               default:
                  print("selected error")
               }
            }

            if feed.transaction?.userLiked == true {
               likeButton.setState(.selected)
            }

            let hashTagBlock = HashTagsScrollModel<Design>().passThroughTouches()
            hashTagBlock.setup(transaction.tags)

            let infoBlock = StackModel()
               .spacing(Grid.x10.value)
               .axis(.vertical)
               .alignment(.fill)
               .arrangedModels([
                  dateLabel,
                  infoLabel,
                  reactionsBlock,
                  hashTagBlock
               ])

            var backColor = Design.color.background
            if type == .youGotAmountFromSome || type == .youGotAmountFromAnonym {
               backColor = Design.color.successSecondary
            }

            let cellStack = WrappedX(
               StackModel()
                  .padding(.outline(Grid.x8.value))
                  .spacing(Grid.x12.value)
                  .axis(.horizontal)
                  .alignment(.top)
                  .arrangedModels([
                     icon,
                     infoBlock
                  ])
                  .backColor(backColor)
                  .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            )
            .padding(.init(top: 8, left: 16, bottom: 8, right: 16))

            work.success(result: cellStack)

         } else if feed.winner != nil {
            let icon = self.makeIcon(feed: feed, type: EventType.winner)
            let infoLabel = FeedPresenters.makeInfoLabel(feed: feed, eventType: EventType.winner)
            let winnerTgName = FeedPresenters.getDisplayNameForWinner(feed.winner)//"@" + (feed.winner?.winnerTgName ?? "")
            let winnerId = feed.winner?.winnerId
            
            infoLabel.view.on(\.didSelect) {
               switch $0 {
               case winnerTgName:
                  self.send(\.didSelect, winnerId ?? -1)
               default:
                  print("selected error")
               }
            }

            let infoBlock = StackModel()
               .spacing(Grid.x10.value)
               .axis(.vertical)
               .alignment(.fill)
               .arrangedModels([
                  dateLabel,
                  infoLabel
               ])

            let cellStack = WrappedX(
               StackModel()
                  .padding(.outline(Grid.x8.value))
                  .spacing(Grid.x12.value)
                  .axis(.horizontal)
                  .alignment(.top)
                  .arrangedModels([
                     icon,
                     infoBlock
                  ])
                  .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            )
            .padding(.init(top: 8, left: 16, bottom: 8, right: 16))

            work.success(result: cellStack)

         } else if feed.challenge != nil {
            let icon = self.makeIcon(feed: feed, type: EventType.challenge)
            let infoLabel = FeedPresenters.makeInfoLabel(feed: feed, eventType: EventType.challenge)
            
            let createrTgName = FeedPresenters.getDisplayNameForChallCreator(feed.challenge)//"@" + (feed.challenge?.creatorTgName ?? "")
            let creatorId = feed.challenge?.creatorId

            infoLabel.view.on(\.didSelect) {
               switch $0 {
               case createrTgName:
                  self.send(\.didSelect, creatorId ?? -1)
               default:
                  print("selected error")
               }
            }
            
            if feed.challenge?.userLiked == true {
               likeButton.setState(.selected)
            }

            let infoBlock = StackModel()
               .spacing(Grid.x10.value)
               .axis(.vertical)
               .alignment(.fill)
               .arrangedModels([
                  dateLabel,
                  infoLabel,
                  reactionsBlock
               ])
            let cellStack = WrappedX(
               StackModel()
                  .padding(.outline(Grid.x8.value))
                  .spacing(Grid.x12.value)
                  .axis(.horizontal)
                  .alignment(.top)
                  .arrangedModels([
                     icon,
                     infoBlock
                  ])
                  .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            )
            .padding(.init(top: 8, left: 16, bottom: 8, right: 16))

            work.success(result: cellStack)
         } else {
            let icon = self.makeIcon(feed: feed, type: EventType.winner)
            let infoLabel = FeedPresenters.makeInfoLabel(feed: feed, eventType: EventType.winner)
            let winnerTgName = FeedPresenters.getDisplayNameForWinner(feed.winner)//"@" + (feed.winner?.winnerTgName ?? "")
            let winnerId = feed.winner?.winnerId

            infoLabel.view.on(\.didSelect) {
               switch $0 {
               case winnerTgName:
                  self.send(\.didSelect, winnerId ?? -1)
               default:
                  print("selected error")
               }
            }

            let infoBlock = StackModel()
               .spacing(Grid.x10.value)
               .axis(.vertical)
               .alignment(.fill)
               .arrangedModels([
                  dateLabel,
                  infoLabel
               ])

            let cellStack = WrappedX(
               StackModel()
                  .padding(.outline(Grid.x8.value))
                  .spacing(Grid.x12.value)
                  .axis(.horizontal)
                  .alignment(.top)
                  .arrangedModels([
                     icon,
                     infoBlock
                  ])
                  .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            )
               .padding(.init(top: 8, left: 16, bottom: 8, right: 16))

            work.success(result: cellStack)
         }
      }
   }
}


extension FeedPresenters {
   static func getDisplayNameForSender(transaction: EventTransaction?) -> String {
      var displayName = ""
      if let firstName = transaction?.senderFirstName, firstName.count > 0 {
         displayName = firstName
      }
      if let surname = transaction?.senderSurname, surname.count > 0 {
         displayName += " " + surname
      }
      if displayName.count == 0 {
         displayName = "@" + (transaction?.senderTgName.unwrap ?? "")
      }
      return displayName
   }
   
   static func getDisplayNameForRecipient(transaction: EventTransaction?) -> String {
      var displayName = ""
      if let firstName = transaction?.recipientFirstName, firstName.count > 0 {
         displayName = firstName
      }
      if let surname = transaction?.recipientSurname, surname.count > 0 {
         displayName += " " + surname
      }
      if displayName.count == 0 {
         displayName = "@" + (transaction?.recipientTgName.unwrap ?? "")
      }
      return displayName
   }
   
   static func getDisplayNameForWinner(_ winner: Feed.Winner?) -> String {
      var displayName = ""
      if let firstName = winner?.winnerFirstName, firstName.count > 0 {
         displayName = firstName
      }
      if let surname = winner?.winnerSurname, surname.count > 0 {
         displayName += " " + surname
      }
      if displayName.count == 0 {
         displayName = "@" + (winner?.winnerTgName.unwrap ?? "")
      }
      return displayName
   }
   
   static func getDisplayNameForChallCreator(_ challenge: Feed.Challenge?) -> String {
      var displayName = ""
      if let firstName = challenge?.creatorFirstName, firstName.count > 0 {
         displayName = firstName
      }
      if let surname = challenge?.creatorSurname, surname.count > 0 {
         displayName += " " + surname
      }
      if displayName.count == 0 {
         displayName = "@" + (challenge?.creatorTgName.unwrap ?? "")
      }
      return displayName
   }
}

extension FeedPresenters {
   static func makeInfoDateLabel(feed: Feed) -> LabelModel {
      let dateAgoText = feed.time?.timeAgoConverted
      var eventText = ""
      if let anon = feed.transaction?.isAnonymous {
         eventText = anon ? "" : " • " + Design.text.publicGratitude
      }

      let titleText = dateAgoText.unwrap + eventText

      let dateLabel = LabelModel()
         .numberOfLines(0)
         .set(Design.state.label.regular12)
         .textColor(Design.color.textSecondary)
         .text(titleText)

      return dateLabel
   }

   static func makeInfoDateLabelForTransaction(transaction: EventTransaction) -> LabelModel {
      let dateAgoText = transaction.updatedAt?.timeAgoConverted
      var eventText = ""
      if let anon = transaction.isAnonymous {
         eventText = anon ? "" : " • " + Design.text.publicGratitude
      }

      let titleText = dateAgoText.unwrap + eventText

      let dateLabel = LabelModel()
         .numberOfLines(0)
         .set(Design.state.label.regular12)
         .textColor(Design.color.textSecondary)
         .text(titleText)

      return dateLabel
   }

   static func makeInfoLabel(feed: Feed, type: FeedTransactType? = nil, eventType: EventType) -> LabelModel {
      let infoLabel = LabelModel()
         .numberOfLines(0)
         .set(Design.state.label.regular12)
         .textColor(Design.color.iconBrand)

      let infoText: NSMutableAttributedString = .init(string: "")

      switch eventType {
      case .transaction:
         let recipientName = getDisplayNameForRecipient(transaction: feed.transaction)
         let senderName = getDisplayNameForSender(transaction: feed.transaction)

         let amount = Int(feed.transaction?.amount ?? 0)
         let amountText = Design.text.pluralCurrencyWithValue(amount, case: .accusative)

         guard let type = type else { return infoLabel }
         switch type {
         case .youGotAmountFromSome:
            infoText.append(Design.text.youReceived.colored(Design.color.text))
            infoText.append(amountText.colored(Design.color.textSuccess))
            infoText.append(Design.text.fromLowercase.colored(Design.color.text))
            infoText.append(senderName.colored(Design.color.textBrand))
         case .youGotAmountFromAnonym:
            infoText.append(Design.text.youReceived.colored(Design.color.text))
            infoText.append(amountText.colored(Design.color.textSuccess))
            //infoText.append(" от аноним".colored(Design.color.text))
         case .someGotAmountFromSome:
            infoText.append(recipientName.colored(Design.color.textBrand))
            infoText.append(Design.text.someoneReceived.colored(Design.color.text))
            infoText.append(amountText.colored(Design.color.textSuccess))
            infoText.append(Design.text.fromLowercase.colored(Design.color.text))
            infoText.append(senderName.colored(Design.color.textBrand))
         case .someGotAmountFromAnonym:
            infoText.append(recipientName.colored(Design.color.textBrand))
            infoText.append(Design.text.someoneReceived.colored(Design.color.text))
            infoText.append(amountText.colored(Design.color.textSuccess))
            //infoText.append(" от аноним".colored(Design.color.text))
         }

         infoLabel.attributedText(infoText)

         infoLabel.view.makePartsClickable(substring1: recipientName, substring2: senderName)
      case .winner:
         let winnerName = FeedPresenters.getDisplayNameForWinner(feed.winner) //"@" + (feed.winner?.winnerTgName ?? "")
         let challengeName = "«" + (feed.winner?.challengeName ?? "") + "»"
         infoText.append(winnerName.colored(Design.color.textBrand))
         infoText.append(Design.text.wonTheChallenge.colored(Design.color.text))
         infoText.append(challengeName.colored(Design.color.textBrand))

         infoLabel.attributedText(infoText)
         infoLabel.view.makePartsClickable(substring1: winnerName, substring2: nil)
         
      case .challenge:
         let challengeName = "«" + (feed.challenge?.name ?? "") + "»"
         let creatorName = FeedPresenters.getDisplayNameForChallCreator(feed.challenge)//"@" + (feed.challenge?.creatorTgName ?? "")
         infoText.append(Design.text.challengeCreated.colored(Design.color.text))
         infoText.append(challengeName.colored(Design.color.textBrand))
         infoText.append(Design.text.byUser.colored(Design.color.text))
         infoText.append(creatorName.colored(Design.color.textBrand))

         infoLabel.attributedText(infoText)
         infoLabel.view.makePartsClickable(substring1: creatorName, substring2: nil)
         
      }
      return infoLabel
   }

   func makeIcon(feed: Feed, type: EventType) -> ImageViewModel {
      let icon = ImageViewModel()
         .contentMode(.scaleAspectFill)
         // .image(Design.icon.newAvatar)
         .cornerCurve(.continuous).cornerRadius(Grid.x36.value / 2)
         .size(.square(Grid.x36.value))

      switch type {
      case .transaction:
         if let recipientPhoto = feed.transaction?.recipientPhoto {
            icon.url(SpasibkaEndpoints.convertToImageUrl(recipientPhoto), placeHolder: Design.icon.avatarPlaceholder)
         } else {
            let userIconText =
               String(feed.transaction?.recipientFirstName?.first ?? "?") +
               String(feed.transaction?.recipientSurname?.first ?? "?")
//            icon
//               .textImage(userIconText, Design.color.backgroundBrand)
//               .backColor(Design.color.backgroundBrand)
            // TODO: - сделать через .textImage
            DispatchQueue.global(qos: .default).async {
               let image = userIconText.drawImage(backColor: Design.color.backgroundBrand)
               DispatchQueue.main.async {
                  icon
                     .backColor(Design.color.backgroundBrand)
                     .image(image)
               }
            }

            // icon.image(Design.icon.newAvatar)
         }
      case .winner:
         if let winnerPhoto = feed.winner?.winnerPhoto {
            icon.url(SpasibkaEndpoints.convertToImageUrl(winnerPhoto), placeHolder: Design.icon.avatarPlaceholder)
         } else {
            // icon.image(Design.icon.newAvatar)
            let userIconText =
               String(feed.winner?.winnerFirstName?.first ?? "?") +
               String(feed.winner?.winnerSurname?.first ?? "?")
            // TODO: - сделать через .textImage
            DispatchQueue.global(qos: .default).async {
               let image = userIconText.drawImage(backColor: Design.color.backgroundBrand)
               DispatchQueue.main.async {
                  icon
                     .backColor(Design.color.backgroundBrand)
                     .image(image)
               }
            }

//            icon
//               .textImage(userIconText, Design.color.backgroundBrand)
//               .backColor(Design.color.backgroundBrand)
         }
      case .challenge:
         icon.image(Design.icon.challengeAvatar)
      }

      return icon
   }
}

enum FeedTransactType {
   static func make(feed: Feed, currentUserName: String) -> Self {
      if feed.transaction?.recipientTgName == currentUserName {
         if feed.transaction?.isAnonymous ?? false {
            return .youGotAmountFromAnonym
         } else {
            return .youGotAmountFromSome
         }
      }
      if feed.transaction?.isAnonymous ?? false {
         return .someGotAmountFromAnonym
      }
      return .someGotAmountFromSome
   }

   static func makeForTransaction(transaction: EventTransaction, currentUserName: String) -> Self {
      if transaction.recipientTgName == currentUserName {
         if transaction.isAnonymous ?? false {
            return .youGotAmountFromAnonym
         } else {
            return .youGotAmountFromSome
         }
      }
      if transaction.isAnonymous ?? false {
         return .someGotAmountFromAnonym
      }
      return .someGotAmountFromSome
   }

   case youGotAmountFromSome
   case youGotAmountFromAnonym

   case someGotAmountFromSome
   case someGotAmountFromAnonym
}

extension FeedPresenters: Eventable {

}

struct FeedUserActionEvents: InitProtocol {
   var didSelect: Int?
   var reactionPressed: PressLikeRequest?
   var didTapLink: URL?
}

enum EventType {
   case transaction
   case winner
   case challenge
}
