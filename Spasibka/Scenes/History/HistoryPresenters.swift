//
//  HistoryPresenters.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 18.08.2022.
//

import StackNinja
import UIKit

final class HistoryPresenters<Design: DesignProtocol>: Designable {
   var events: EventsStore = .init()

   var transactToHistoryCell: CellPresenterWork<TransactionItem, WrappedX<StackModel>> {
      CellPresenterWork { [weak self] work in
         guard let self = self else { return }
         
         let item = work.unsafeInput.item
         
         guard let transactClass = item.transactClass?.id else {return }
         
         let icon = self.makeIcon(item: item)

         let senderName = HistoryPresenters.getDisplayNameForSender(transactionItem: item)
         let recipientName = HistoryPresenters.getDisplayNameForRecipient(transactionItem: item)
         
         var amountText = Design.text.pluralCurrencyWithValue(item.amount, case: .accusative)
         let challengeName = item.sender.challengeName ?? ""
         
         let dateLabel = LabelModel()
            .numberOfLines(1)
            .set(Design.state.label.descriptionSecondary12)
         
         if let dateText = item.createdAt.dateConverted(inputFormat: .yyyyMMddTHHmmssSSSSSSZ, outputFormat: .ddMMyyyy) {
            var text = dateText
            if let date = item.createdAt.dateConvertedToDate {
               if Calendar.current.isDateInToday(date) {
                  text = Design.text.today
               } else if Calendar.current.isDateInYesterday(date) {
                  text = Design.text.yesterday
               }
               if let time = item.createdAt.dateConverted(inputFormat: .yyyyMMddTHHmmssSSSSSSZ, outputFormat: .hhMM) {
                   text += Design.text.inLowercase + time
               }
            }
            dateLabel.text(text)
         }
         
         let infoLabel = LabelModel()
            .numberOfLines(0)
            .set(Design.state.label.descriptionRegular12)
            .textColor(Design.color.iconBrand)
         
         let titleLabel = LabelModel()
            .numberOfLines(1)
            .set(Design.state.label.labelRegular14)

         let infoText: NSMutableAttributedString = .init(string: "")
         
         switch transactClass {
         case "T":
            titleLabel.text(Design.text.gratitude)
            if item.state == .recieved {
               amountText = "+" + amountText
               infoText.append(amountText.colored(Design.color.textSuccess))
               
               if !item.isAnonymous {
                  infoText.append(Design.text.fromLowercase.colored(Design.color.text))
                  infoText.append(senderName.colored(Design.color.textBrand))
               } else {
                  infoText.insert(Design.text.youReceived.colored(Design.color.text), at: 0)
               }
            } else {
               amountText = amountText
               infoText.append(amountText.colored(Design.color.textError))
               infoText.append(Design.text.forLowercase.colored(Design.color.text))
               infoText.append(recipientName.colored(Design.color.textBrand))
            }
         case "D", "M":
            titleLabel.text(Design.text.systemRefill)
            amountText = "+" + amountText
            infoText.append(amountText.colored(Design.color.textSuccess))
            infoText.append(Design.text.refillFromSystem.colored(Design.color.text))
         case "H":
            titleLabel.text(Design.text.creatingChallenge)
            infoText.append(amountText.colored(Design.color.textError))
            infoText.append(Design.text.forChallengeFee.colored(Design.color.text))
            infoText.append(challengeName.colored(Design.color.textBrand))
         case "W":
            titleLabel.text(Design.text.winningTheChallenge)
            amountText = "+" + amountText
            infoText.append(amountText.colored(Design.color.textSuccess))
            infoText.append(Design.text.challengeReward.colored(Design.color.text))
            infoText.append(challengeName.colored(Design.color.textBrand))
         case "F":
            titleLabel.text(Design.text.refundPrizeFund)
            amountText = "+" + amountText
            infoText.append(amountText.colored(Design.color.textSuccess))
            infoText.append(Design.text.refundFromChallenge.colored(Design.color.text))
            infoText.append(challengeName.colored(Design.color.textBrand))
         case "P":
            titleLabel.text(Design.text.purchaseBenefit)
            infoText.append(amountText.colored(Design.color.textError))
            infoText.append(Design.text.purchase.colored(Design.color.text))
         case "I":
            titleLabel.text(Design.text.refundBenefit)
            amountText = "+" + amountText
            infoText.append(amountText.colored(Design.color.textSuccess))
            infoText.append(Design.text.refundFromMarket.colored(Design.color.text))
         case "B":
            titleLabel.text(Design.text.systemDebit)
            infoText.append(amountText.colored(Design.color.textError))
         default:
            print(item)
         }
         
         infoLabel.attributedText(infoText)
         
         let cancelButton = ImageViewModel()
            .image(Design.icon.cross)
            .imageTintColor(Design.color.textError)
            .set(.tapGesturing)
            .size(.square(25))
            .hidden(true)
            .padding(.init(top: 7, left: 6, bottom: -7, right: -6))
         
         cancelButton.view.on(\.didTap, self) {
            $0.send(\.presentAlert, item.id ?? 0)
         }
         
         if item.canUserCancel == true {
            cancelButton.hidden(false)
         }
         
         let firstStack = StackModel()
            .axis(.horizontal)
            .alignment(.leading)
            .distribution(.fill)
            .spacing(4)
            .arrangedModels([
               titleLabel,
               Grid.xxx.spacer,
               dateLabel
            ])

         let secondStack = StackModel()
            .axis(.horizontal)
            .alignment(.leading)
            .distribution(.fill)
            .spacing(4)
            .arrangedModels([
               infoLabel,
               Grid.xxx.spacer,
               cancelButton
            ])

         let infoBlock = StackModel()
            .axis(.vertical)
            .spacing(6)
            .arrangedModels([
               firstStack,
               secondStack,
            ])
         
         let cellStack = WrappedX(
            StackModel()
               .padding(Design.params.cellContentPadding)
               .spacing(Grid.x12.value)
               .axis(.horizontal)
               .alignment(.center)
               .arrangedModels([
                  icon,
                  infoBlock
               ])
               .cornerCurve(.continuous)
               .cornerRadius(Design.params.cornerRadiusSmall)
               .backColor(Design.color.background)
               .shadow(Design.params.newCellShadow)
         )
         .padding(.init(top: 8, left: 16, bottom: 8, right: 16))

         work.success(result: cellStack)
      }
   }
}

extension HistoryPresenters {
   func makeIcon(item: TransactionItem) -> ImageViewModel {
      
      let icon = ImageViewModel()
         .contentMode(.scaleAspectFill)
         .cornerCurve(.continuous).cornerRadius(Grid.x36.value / 2)
         .size(.square(Grid.x36.value))

      
      switch item.transactClass?.id {
      case "T":
         if item.isAnonymous == false {
            var userIconText: String = ""
            var nameFirstLetter = String(item.recipient.recipientFirstName?.first ?? "?")
            var surnameFirstLetter = String(item.recipient.recipientSurname?.first ?? "?")
            var photoUrl = item.recipient.recipientPhoto
            
            if item.isSentTransact == false {
               nameFirstLetter = String(item.sender.senderFirstName?.first ?? "?")
               surnameFirstLetter = String(item.sender.senderSurname?.first ?? "?")
               userIconText = nameFirstLetter + surnameFirstLetter
               photoUrl = item.sender.senderPhoto
            }
            
            userIconText = nameFirstLetter + surnameFirstLetter
            
            if let iconPhoto = photoUrl {
               print(iconPhoto)
               icon.url(SpasibkaEndpoints.urlBase + iconPhoto, placeHolder: Design.icon.avatarPlaceholder)
            } else {

               // TODO: - сделать через .textImage
               DispatchQueue.global(qos: .background).async {
                  let image = userIconText.drawImage(backColor: Design.color.backgroundBrand)
                  DispatchQueue.main.async {
                     icon
                        .backColor(Design.color.backgroundBrand)
                        .image(image)
                  }
               }
            }
         } else {
            icon
               //.image(Design.icon.smallSpasibkaLogo)
               .image(Design.icon.smallSpasibkaLogo.insetted(16)).imageTintColor(Design.color.iconBrand)
               .backColor(Design.color.backgroundBrandSecondary)
               //.imageTintColor(Design.color.iconBrand)
         }
         
      case "H", "W", "F":
         icon.image(Design.icon.medal.insetted(6).withTintColor(Design.color.iconBrand))
      case "B", "D", "M":
         icon.image(Design.icon.desktop.insetted(6).withTintColor(Design.color.iconBrand))
      case "P", "I":
         icon.image(Design.icon.basket.insetted(6).withTintColor(Design.color.iconBrand))
      default:
         icon.image(Design.icon.avatarPlaceholder)
      }

      return icon
   }
}


extension HistoryPresenters: Eventable {
   struct Events: InitProtocol {
      var presentAlert: Int?
      var cancelButtonPressed: Int?
   }
}

extension HistoryPresenters {
   static func getDisplayNameForSender(transactionItem: TransactionItem? = nil, transaction: Transaction? = nil) -> String {
      var displayName = ""
      
      if let sender = transactionItem?.sender ?? transaction?.sender {
         if let firstName = sender.senderFirstName, firstName.count > 0 {
            displayName = firstName
         }
         if let surname = sender.senderSurname, surname.count > 0 {
            displayName += " " + surname
         }
         if displayName.count == 0 {
            displayName = "@" + (sender.senderTgName.unwrap)
         }
      }
      return displayName
   }
   
   static func getDisplayNameForRecipient(transactionItem: TransactionItem? = nil, transaction: Transaction? = nil) -> String {
      var displayName = ""
      if let recipient = transactionItem?.recipient ?? transaction?.recipient {
         if let firstName = recipient.recipientFirstName, firstName.count > 0 {
            displayName = firstName
         }
         if let surname = recipient.recipientSurname, surname.count > 0 {
            displayName += " " + surname
         }
         if displayName.count == 0 {
            displayName = "@" + (recipient.recipientTgName.unwrap)
         }
      }
      return displayName
   }
}
struct TransactionItem {
   enum State {
      case waiting
      case approved
      case declined
      case ingrace
      case ready
      case cancelled
      case recieved
   }

   let state: State
   let sender: Sender
   let recipient: Recipient
   let amount: String
   let createdAt: String
   let photo: String?
   let isAnonymous: Bool
   let id: Int?
   let transactClass: TransactionClass?
   let canUserCancel: Bool?
   let isSentTransact: Bool?
}
