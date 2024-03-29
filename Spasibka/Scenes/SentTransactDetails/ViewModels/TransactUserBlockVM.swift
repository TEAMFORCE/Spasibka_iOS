//
//  TransactUserBlockVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.02.2023.
//

import StackNinja

final class TransactUserBlockVM<Design: DSP>: StackModel {
   private lazy var userAvatar = WrappedY(ImageViewModel()
      .image(Design.icon.newAvatar)
      .contentMode(.scaleAspectFill)
      .cornerCurve(.continuous).cornerRadius(70 / 2)
      .size(.square(70))
   )

   private lazy var transactionOwnerLabel = LabelModel()
      .set(Design.state.label.regular14)
      .numberOfLines(0)
      .alignment(.center)

   private lazy var dateLabel = LabelModel()
      .textColor(Design.color.textSecondary)

   private lazy var amountLabel = LabelModel()

   private lazy var currencyLabel = CurrencyLabelDT<Design>()
      .setAll { label, _, image in
         label
            .height(Grid.x32.value)
            .set(Design.state.label.bold32)
            .textColor(Design.color.success)
         image
            .width(Grid.x26.value)
            .height(Grid.x26.value)
            .imageTintColor(Design.color.success)
      }
      .height(40)

   // MARK: - Funcs

   override func start() {
      super.start()

      padding(.init(top: 16, left: 16, bottom: 16, right: 16))
      distribution(.fill)
      alignment(.center)
      spacing(8)
      arrangedModels([
         userAvatar,
         Spacer(maxSize: 32),
         dateLabel,
         transactionOwnerLabel,
         amountLabel,
         currencyLabel,
      ])
   }
}

extension TransactUserBlockVM: StateMachine {
   func setState(_ state: TransactDetailsState) {
      var input: Transaction

      switch state {
      case let .sentTransaction(value):
         input = value

         currencyLabel.models.main.textColor(Design.color.textError)
         currencyLabel.models.right2.imageTintColor(Design.color.textError)

         currencyLabel.label
            .text(input.amount.unwrap)

         let recipientFullName = HistoryPresenters<Design>.getDisplayNameForRecipient(transaction: input)
//         let recipientFullName = (input.recipient?.recipientFirstName ?? "") + " " +
//         (input.recipient?.recipientSurname ?? "")
         transactionOwnerLabel
            .set(.text("\(Design.text.youSent) \(recipientFullName)"))

         if let urlSuffix = input.recipient?.recipientPhoto {
            let urlString = SpasibkaEndpoints.urlBase + urlSuffix
            userAvatar.subModel.url(urlString)
         } else {
            var userIconText = ""
            if let nameFirstLetter = input.recipient?.recipientFirstName?.first,
               let surnameFirstLetter = input.recipient?.recipientSurname?.first
            {
               userIconText = String(nameFirstLetter) + String(surnameFirstLetter)
            }
            let tempImage = userIconText.drawImage(backColor: Design.color.backgroundBrand)
            userAvatar.subModel
               .image(tempImage)
               .backColor(Design.color.backgroundBrand)
         }

         if let challName = input.sender?.challengeName {
            transactionOwnerLabel
               .set(.text(Design.text.sentForChallenge + challName))
            userAvatar.subModel.image(Design.icon.challengeAvatar)
         }

      case let .recievedTransaction(value):
         input = value

         currencyLabel.label
            .text("+" + input.amount.unwrap)

         let senderFullName = HistoryPresenters<Design>.getDisplayNameForSender(transaction: input)
//         let senderFullName = (input.sender?.senderFirstName ?? "") + " " +
//         (input.sender?.senderSurname ?? "")
         transactionOwnerLabel
            .set(.text("\(Design.text.youReceivedFrom) \(senderFullName)"))
     
         if let urlSuffix = input.sender?.senderPhoto {
            let urlString = SpasibkaEndpoints.urlBase + urlSuffix
            userAvatar.subModel.url(urlString)
         } else {
            var userIconText = ""
            if let nameFirstLetter = input.sender?.senderFirstName?.first,
               let surnameFirstLetter = input.sender?.senderSurname?.first
            {
               userIconText = String(nameFirstLetter) + String(surnameFirstLetter)
            }
            let tempImage = userIconText.drawImage(backColor: Design.color.backgroundBrand)
            userAvatar.subModel
               .image(tempImage)
               .backColor(Design.color.backgroundBrand)
         }
         if input.isAnonymous == true {
            userAvatar.subModel
               .image(Design.icon.smallSpasibkaLogo.insetted(16)).imageTintColor(Design.color.iconBrand)
               .backColor(Design.color.backgroundBrandSecondary)
         }
      }

      let amount = input.amount ?? ""
      let amountText = Design.text.pluralCurrencyWithValue(amount, case: .genitive)
      amountLabel
         .set(.text(amountText))
      
      var textColor = Design.color.text
      switch input.transactionStatus?.id {
      case "A":
         textColor = Design.color.textSuccess
      case "D":
         textColor = Design.color.boundaryError
         transactionOwnerLabel.text(Design.text.youWantedToSend + (input.recipient?.recipientFirstName ?? "") + " " + (input.recipient?.recipientSurname ?? ""))
      case "W":
         textColor = Design.color.textWarning
      default:
         textColor = Design.color.text
      }

      amountLabel.set(.textColor(textColor))

      guard let convertedDate = (input.createdAt ?? "").dateFormatted() else { return }

      dateLabel.set(.text(convertedDate))
   }
}
