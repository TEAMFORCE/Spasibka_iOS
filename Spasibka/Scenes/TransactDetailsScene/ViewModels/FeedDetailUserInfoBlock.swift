//
//  FeedDetailUserInfoBlock.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.10.2022.
//

import Foundation
import StackNinja

extension FeedDetailUserInfoBlock: Eventable {
   struct Events: InitProtocol {
      var reactionPressed: Void?
      var userAvatarPressed: Int?
      var didSelectProfile: Int?
   }
}

final class FeedDetailUserInfoBlock<Design: DSP>: StackModel, Designable {
   var events: EventsStore = .init()
   
   private lazy var typeIcon = ThanksAmountModel<Design>()

   private lazy var typeIconWrapper = WrappedX(typeIcon)
      .backColor(Design.color.background)
      .cornerCurve(.continuous).cornerRadius(43/2)
      .size(.square(43))
      .alignment(.center)
      .distribution(.equalCentering)

   lazy var iconPlace = WrappedX(self.image)
      .addModel(typeIconWrapper) { anchors, view in
         anchors
            .centerX(view.centerXAnchor, 128/3)
            .centerY(view.centerYAnchor, 128/3)
      }
   
   lazy var image = WrappedY(ImageViewModel()
      .image(Design.icon.newAvatar)
      .contentMode(.scaleAspectFill)
      .cornerCurve(.continuous).cornerRadius(128 / 2)
      .size(.square(128))
      .shadow(Design.params.cellShadow)
   )

   lazy var dateLabel = LabelModel()
      .numberOfLines(0)
      .set(Design.state.label.regular12)
      .textColor(Design.color.textSecondary)

   lazy var infoLabel = LabelModel()
      .numberOfLines(0)
      .textColor(Design.color.iconBrand)
      .alignment(.center)
      .padding(.horizontalOffset(16))

   lazy var likeButton = NewLikeButton<Design>()
//   lazy var likesAmountLabel = LabelModel()
//      .numberOfLines(1)
//      .set(Design.state.label.labelRegular10)
//      .textColor(Design.color.textContrastSecondary)
//      .text(Design.text.liked)

   lazy var reactionsBlock = StackModel()
      .axis(.horizontal)
      .alignment(.trailing)
      .distribution(.fill)
      .spacing(8)
      .arrangedModels([
         Grid.xxx.spacer,
         likeButton,
         Grid.xxx.spacer,
//         likesAmountLabel,
         //Grid.xxx.spacer
      ])

   override func start() {
      super.start()

      alignment(.center)
      arrangedModels([
//         image,
         iconPlace,
         Spacer(20),
        // dateLabel,
         //Spacer(8),
         infoLabel,
         Spacer(16),
         reactionsBlock,
//         likeButton,
         Spacer(20)
      ])
   }
}

extension FeedDetailUserInfoBlock: SetupProtocol {
   func makeInfoLabel(transaction: EventTransaction, type: FeedTransactType) -> LabelModel {
      let infoLabel = LabelModel()
         .numberOfLines(0)
         .set(Design.state.label.descriptionRegular14)
         .textColor(Design.color.iconBrand)

      let infoText: NSMutableAttributedString = .init(string: "")

      let recipientName = FeedPresenters<Design>.getDisplayNameForRecipient(transaction: transaction)
      let senderName = FeedPresenters<Design>.getDisplayNameForSender(transaction: transaction)

      let amount = transaction.amount
      let amountText = Design.text.pluralCurrencyWithValue(amount, case: .accusative)
      switch type {
      case .youGotAmountFromSome:
         infoText.append(Design.text.youReceived.colored(Design.color.text))
         infoText.append(amountText.colored(Design.color.textSuccess))
         infoText.append(Design.text.fromLowercase.colored(Design.color.text))
         infoText.append(NSAttributedString(string: "\n"))
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
         infoText.append(NSAttributedString(string: "\n"))
         infoText.append(senderName.colored(Design.color.textBrand))
      case .someGotAmountFromAnonym:
         infoText.append(recipientName.colored(Design.color.textBrand))
         infoText.append(Design.text.someoneReceived.colored(Design.color.text))
         infoText.append(amountText.colored(Design.color.textSuccess))
         //infoText.append(" от аноним".colored(Design.color.text))
      }

//      infoLabel.attributedText(infoText)

//      infoLabel.view.makePartsClickable(substring1: recipientName, substring2: senderName)

      infoLabel.attributedText(infoText)

      return infoLabel
   }

   func setup(_ data: (transaction: EventTransaction, currentUserName: String)) {
      let transaction = data.transaction
      let userName = data.currentUserName
//      configureImage(transaction: transaction)
      configureImageWithUrlAndInitials(url: transaction.recipientPhoto,
                                       firstname: transaction.recipientFirstName,
                                       surname: transaction.recipientSurname)
      configureEvents(transaction: transaction, userId: transaction.recipientId)
      let dateText = FeedPresenters<Design>.makeInfoDateLabelForTransaction(transaction: transaction).view.text
      dateLabel.text(dateText ?? "--:--")
      let type = FeedTransactType.makeForTransaction(
         transaction: transaction,
         currentUserName: userName
      )
//      let infoText = FeedPresenters<Design>.makeInfoLabel(feed: feed, type: type, eventType: EventType.transaction).view.attributedText
//
//            infoLabel.attributedText(infoText!)
      let infoText = makeInfoLabel(transaction: transaction, type: type).view.attributedText
      infoLabel.attributedText(infoText!)
      let senderName = FeedPresenters<Design>.getDisplayNameForSender(transaction: transaction)
      let recipientName = FeedPresenters<Design>.getDisplayNameForRecipient(transaction: transaction)
      let senderId = transaction.senderId
      let recipientId = transaction.recipientId
      infoLabel.view.makePartsClickable(substring1: recipientName, substring2: senderName)
      
      infoLabel.view.on(\.didSelect) {
         switch $0 {
         case senderName:
            self.send(\.didSelectProfile, senderId ?? -1)
         case recipientName:
            self.send(\.didSelectProfile, recipientId ?? -1)
         default:
            print("selected error")
         }
      }
//      let likeAmount = String(transaction.likeAmount ?? 0)

//      likeButton.models.right.text(likeAmount)
//      likesAmountLabel.text(Design.text.liked + " " + likeAmount)

      if transaction.userLiked == true {
         likeButton.setState(.selected)
      }
      
      typeIcon.amountText = transaction.amount.toString
   }
   
   func setupContenderInfo(contender: Contender) {
      configureEvents(userId: contender.participantId)
      configureImageWithUrlAndInitials(
         url: contender.participantPhoto,
         firstname: contender.participantName,
         surname: contender.participantSurname)
      
      dateLabel.text(contender.reportCreatedAt.timeAgoConverted)
      
//      let likeAmount = String(contender.likesAmount ?? 0)

//      likeButton.models.right.text(likeAmount)
//      likesAmountLabel.text(Design.text.liked + " " + likeAmount)

      if contender.userLiked == true {
         likeButton.setState(.selected)
      }
      var nameText = "\(contender.participantName.unwrap) \(contender.participantSurname.unwrap)".colored(Design.color.text)
      infoLabel.attributedText(nameText)
   }
   
   func setupWinnerInfo(report: ChallengeReport) {
      configureEvents(userId: report.user.id)
      configureImageWithUrlAndInitials(
         url: report.user.avatar,
         firstname: report.user.name,
         surname: report.user.surname)
      
      dateLabel.text(report.createdAt?.timeAgoConverted ?? "")
      
//      let likeAmount = String(report.likesAmount ?? 0)

//      likeButton.models.right.text(likeAmount)
//      likesAmountLabel.text(Design.text.liked + " " + likeAmount)

      if report.userLiked == true {
         likeButton.setState(.selected)
      }
      var nameText = "\(report.user.name.unwrap) \(report.user.surname.unwrap)".colored(Design.color.text)
      infoLabel.attributedText(nameText)
   }
}

private extension FeedDetailUserInfoBlock {
   func configureImageWithUrlAndInitials(url: String?, firstname: String?, surname: String?) {
      if let avatarUrl = url {
         image.subModel.url(SpasibkaEndpoints.urlBase + avatarUrl)
      } else {
         // TODO: - сделать через .textImage
         let userIconText =
            String(firstname?.first ?? "?") +
            String(surname?.first ?? "?")
         DispatchQueue.global(qos: .background).async {
            let image = userIconText.drawImage(backColor: Design.color.backgroundBrand)
            DispatchQueue.main.async { [weak self] in
               self?.image.subModel
                  .backColor(Design.color.backgroundBrand)
                  .image(image.insetted(10))
            }
         }
      }
   }

   func configureEvents(transaction: EventTransaction? = nil, userId: Int? = nil) {
      likeButton.view.startTapGestureRecognize()
      likeButton.view.on(\.didTap, self) {
         $0.send(\.reactionPressed)
      }

      guard
         // let userId = feed.transaction?.recipientId ?? feed.challenge?.creatorId ?? feed.winner?.winnerId
         let userId = userId //transaction?.recipientId
      else {
         return
      }

      image.view.startTapGestureRecognize()
      image.view.on(\.didTap, self) {
         $0.send(\.userAvatarPressed, userId)
      }
   }
   

   
}
