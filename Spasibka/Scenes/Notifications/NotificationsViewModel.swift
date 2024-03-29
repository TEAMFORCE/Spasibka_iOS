//
//  NotificationsViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.11.2022.
//

import StackNinja
import UIKit

enum NotificationForWhat {
   case challenge
   case transaction
}

final class NotificationsViewModel<Design: DSP>: StackModel, Designable {
   var events = EventsStore()

   let backColor = UIColor(red: 0.542, green: 0.542, blue: 0.542, alpha: 0)
   lazy var tableModel = TableItemsModel()
      .backColor(Design.color.background)
      .headerParams(labelState: Design.state.label.labelRegularContrastColor14, backColor: backColor /*Design.color.background*/)
      .footerModel(Spacer(96))
      .setNeedsLayoutWhenContentChanged()
   
   lazy var presenter = NotificationsPresenter<Design>()
   
   private var amountOfUnreadNotificationsLabel: LabelModel =
      Design.label.descriptionMedium12
         .text("У вас 0 новых уведомления")


   override func start() {
      super.start()

      arrangedModels([
         Spacer(8),
         amountOfUnreadNotificationsLabel.padLeft(16),
         Spacer(8),
         tableModel
      ])
      

      tableModel.on(\.didSelectItemAtIndex, self) {
         $0.send(\.didSelectRow, $1)
      }
   }
}

extension NotificationsViewModel: Eventable {
   struct Events: InitProtocol {
      var didSelectRow: Int?
   }
}

enum NotifyVMState {
   case tableData([TableItemsSection])
   case setUnreadNotificationsAmount(Int)
}

extension NotificationsViewModel: StateMachine {
   func setState(_ state: NotifyVMState) {
      switch state {
      case .tableData(let sections):
         var sections = sections
         if let lastSection = sections.last {
            sections[sections.count - 1] = lastSection
         }
         tableModel.itemSections(sections)
      case .setUnreadNotificationsAmount(let amount):
         if amount % 10 == 1, amount % 10 != 11 {
            amountOfUnreadNotificationsLabel
               .text("\(Design.text.youHave) \(amount) \(Design.text.newNotification)")
         } else {
            amountOfUnreadNotificationsLabel
               .text("\(Design.text.youHave) \(amount) \(Design.text.newNotifications)")
         }
      }
   }
}

class NotificationsPresenter<Design: DSP>: Designable {
   var notifyCell: CellPresenterWork<Notification, WrappedX<StackModel>> {
      CellPresenterWork { work in
         let item = work.unsafeInput.item
         
         let icon = self.makeIcon(item: item)
         
         let dateLabel = LabelModel()
            .numberOfLines(1)
            .set(Design.state.label.descriptionSecondary12)
         
//         if let dateText = item.createdAt?.dateConverted(inputFormat: .yyyyMMddTHHmmssSSSSSSZ, outputFormat: .ddMMyyyy) {
//            dateLabel.text(dateText)
//         }
         
         if let dateText = item.createdAt?.dateConverted(inputFormat: .yyyyMMddTHHmmssSSSSSSZ, outputFormat: .ddMMyyyy) {
            var text = dateText
            if let date = item.createdAt?.dateConvertedToDate {
               if Calendar.current.isDateInToday(date) {
                  text = Design.text.today
                  if let time = item.createdAt?.dateConverted(inputFormat: .yyyyMMddTHHmmssSSSSSSZ, outputFormat: .hhMM) {
                     text = time
                  }
               } else if Calendar.current.isDateInYesterday(date) {
                  text = Design.text.yesterday
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

         let titleText = self.makeTitle(item: item)
         titleLabel.text(titleText)

         let infoText: NSMutableAttributedString = self.makeInfoText(data: item)
         infoLabel.attributedText(infoText)
         
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
               Grid.xxx.spacer
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

extension NotificationsPresenter {
   func makeIcon(item: Notification) -> ImageViewModel {
      
      var icon = ImageViewModel()
         .contentMode(.scaleAspectFill)
         .cornerCurve(.continuous).cornerRadius(Grid.x36.value / 2)
         .size(.square(Grid.x36.value))
         .borderColor(Design.color.infoSecondary)
         .borderWidth(0.5)
         .backColor(Design.color.iconBrandSecondary)

      
      switch item.type {
      case .transactAdded:
         icon = makeTextIconIfNeeded(firstname: item.transactionData?.senderFirstname,
                             surname: item.transactionData?.senderSurname,
                             photoUrl: item.transactionData?.senderPhoto)
      case .challengeWin, .challengeCreated, .challengeFinished, .newReportToChallenge:
         icon.image(Design.icon.medal.insetted(6).withTintColor(Design.color.iconBrand))
      case .marketplace:
         icon.image(Design.icon.basket.insetted(6).withTintColor(Design.color.iconBrand))
      case .questionnaire:
         icon.image(Design.icon.notepad.insetted(12).withTintColor(Design.color.iconBrand))
      case .likeAdded:
         icon = makeTextIconIfNeeded(firstname: item.likeData?.reactionFromFirstName,
                             surname: item.likeData?.reactionFromSurname,
                             photoUrl: item.likeData?.reactionFromPhoto)
      case .commentAdded:
         icon = makeTextIconIfNeeded(firstname: item.commentData?.commentFromFirstName,
                             surname: item.commentData?.commentFromSurname,
                             photoUrl: item.commentData?.commentFromPhoto)
      default:
         icon.image(Design.icon.avatarPlaceholder)
      }

      return icon
   }
   
   func makeTitle(item: Notification) -> String {
      switch item.type {
      case .transactAdded:
         return Design.text.notificationTitleGratitude
      case .commentAdded:
         return Design.text.notificationTitleComment
      case .likeAdded:
         return Design.text.notificationTitleReaction
      case .challengeWin:
         return Design.text.notificationTitleNewVictory
      case .newReportToChallenge:
         return Design.text.notificationTitleNewApplication
      case .marketplace:
         return Design.text.notificationTitleNewOrder
      case .challengeFinished:
         return Design.text.notificationTitleChallengeExpiration
      case .questionnaire:
         if let mode = item.questionnaireData?.mode {
            switch mode {
            case 1, 2, 3:
               return Design.text.notificationTitleSurveyExpiration
            case 4:
               return Design.text.notificationTitleNewSurvey
            default:
               return ""
            }
         }
         return Design.text.notificationTitleNewSurvey
      case .challengeCreated:
         return Design.text.notificationTitleChallenge
      case .none:
         return ""
      }
   }
   func takeShowName(firstName: String?, surname: String?, tgName: String?) -> String {
      var result = ""
      if let firstName = firstName {
         result = firstName
      }
      if let surname = surname {
         if !result.isEmpty {
            result += " "
         }
         result += surname
      }
      if result.isEmpty {
         if let tgName = tgName {
            result = tgName
         }
      }
      return result
   }
   
   func makeTextIconIfNeeded(firstname: String?, surname: String?, photoUrl: String?) -> ImageViewModel {
      let icon = ImageViewModel()
         .contentMode(.scaleAspectFill)
         .cornerCurve(.continuous).cornerRadius(Grid.x36.value / 2)
         .size(.square(Grid.x36.value))
         .borderColor(Design.color.infoSecondary)
         .borderWidth(0.5)
         .backColor(Design.color.iconBrandSecondary)
      
      if let photo = photoUrl {
         icon.url(SpasibkaEndpoints.urlBase + photo)
      } else {
         let firstnameLetter = firstname?.first?.toString ?? ""
         let surnameLetter = surname?.first?.toString ?? ""
         let imageText = firstnameLetter + surnameLetter
         if imageText.isEmpty {
            icon.image(Design.icon.avatarPlaceholder)
         } else {
            let image = imageText.drawImage(backColor: Design.color.backgroundBrand)
            icon
               .backColor(Design.color.backgroundBrand)
               .image(image)
         }
      }
      return icon
   }
   func makeInfoText(data: Notification) -> NSMutableAttributedString {
      let infoText: NSMutableAttributedString = .init(string: "")
      
      switch data.type {
      case .transactAdded:
         let transactionData = data.transactionData
//         let tgName = data.transactionData?.senderTgName
         let showName = takeShowName(firstName: transactionData?.senderFirstname,
                                     surname: transactionData?.senderSurname,
                                     tgName: transactionData?.senderTgName)
         let amount = Int(data.transactionData?.amount ?? 0)
         let amountText = Design.text.pluralCurrencyWithValue(amount, case: .accusative)
         if data.transactionData?.senderId == nil {
            infoText.append(Design.text.youReceived.colored(Design.color.text))
            infoText.append(amountText.colored(Design.color.textBrand))
         } else {
            infoText.append(Design.text.youReceived.colored(Design.color.text))
            infoText.append(amountText.colored(Design.color.textBrand))
            infoText.append(Design.text.fromLowercase.colored(Design.color.text))
            infoText.append(showName.colored(Design.color.textBrand))
         }
      case .commentAdded:
         let commentData = data.commentData
         let showName = takeShowName(firstName: commentData?.commentFromFirstName,
                                     surname: commentData?.commentFromSurname,
                                     tgName: commentData?.commentFromTgName)
         let forWhat: NotificationForWhat = commentData?.challengeId != nil ? .challenge : .transaction
         let text = forTextForReactionCommendReport(showname: showName,
                                                    notificationType: .commentAdded,
                                                    forWhat: forWhat)
         infoText.append(text)
      case .likeAdded:
         let likeData = data.likeData
         let showName = takeShowName(firstName: likeData?.reactionFromFirstName,
                                     surname: likeData?.reactionFromSurname,
                                     tgName: likeData?.reactionFromTgName)
         
         let forWhat: NotificationForWhat = likeData?.challengeId != nil ? .challenge : .transaction
         let text = forTextForReactionCommendReport(showname: showName,
                                                    notificationType: .likeAdded,
                                                    forWhat: forWhat)
         infoText.append(text)
      case .challengeWin:
         let challengeName = data.winnerData?.challengeName
         infoText.append(Design.text.youWonChallenge.colored(Design.color.text))
         infoText.append(challengeName.string.colored(Design.color.textBrand))
      case .newReportToChallenge:
         let reportData = data.reportData
         let showName = takeShowName(firstName: reportData?.reportSenderFirstName,
                                     surname: reportData?.reportSenderSurname,
                                     tgName: reportData?.reportSenderTgName)
         let forWhat = NotificationForWhat.challenge
         let text = forTextForReactionCommendReport(showname: showName,
                                                    notificationType: .newReportToChallenge,
                                                    forWhat: forWhat)

         infoText.append(text)
      case .challengeCreated:
         let challengeName = "\"" + (data.challengeData?.challengeName.string ?? "") + "\""
//         infoText.append((data.theme + " ").colored(Design.color.text))
         infoText.append(Design.text.newChallengePrefix.colored(Design.color.text))
         infoText.append(challengeName.colored(Design.color.textBrand))
         break
      case .challengeFinished:
         let challengeEndingData = data.challengeEndingData
         let challengeName = data.challengeEndingData?.challengeName
         infoText.append(Design.text.challengePrefix.colored(Design.color.text))
         infoText.append(challengeName.unwrap.colored(Design.color.textBrand))
         infoText.append(Design.text.finishesTommorow.colored(Design.color.text))
      case .marketplace:
         let offerName = "\"" + (data.orderData?.offerName ?? "") + "\""
         let customerName = data.orderData?.customerName ?? ""
         infoText.append(Design.text.newOrderFor.colored(Design.color.text))
         infoText.append(offerName.colored(Design.color.textBrand))
         infoText.append(Design.text.fromLowercase.colored(Design.color.text))
         infoText.append(customerName.colored(Design.color.textBrand))
      case .questionnaire:
         let questionnaireName = data.questionnaireData?.questionnaireTitle.unwrap
         let finishTime = data.questionnaireData?.finishedAt
         if let mode = data.questionnaireData?.mode {
            switch mode {
            case 1:
               infoText.append(Design.text.allParticipantsFinishedSurvey.colored(Design.color.text))
               infoText.append((questionnaireName.string + " ").colored(Design.color.textBrand))
            case 2:
               infoText.append(Design.text.tommorowAt.colored(Design.color.text))
               infoText.append(finishTime.unwrap.colored(Design.color.text))
               infoText.append(Design.text.closesAccessToSurvey.colored(Design.color.text))
               infoText.append(questionnaireName.string.colored(Design.color.textBrand))
            case 3:
               infoText.append(Design.text.tommorowAt.colored(Design.color.text))
               infoText.append(finishTime.unwrap.colored(Design.color.text))
               infoText.append(Design.text.finishesSurvey.colored(Design.color.text))
               infoText.append(questionnaireName.string.colored(Design.color.textBrand))
               infoText.append(Design.text.hurryUpToParticipate.colored(Design.color.text))
            case 4:
               infoText.append(Design.text.createdNewSurvey.colored(Design.color.text))
               infoText.append(questionnaireName.string.colored(Design.color.textBrand))
            default:
               break
            }
         }
         break
      case .none:
         break
      }
      return infoText
   }
   
   func formTextForNotification(theme: String, name: String?, surname: String?, tgName: String?) -> NSMutableAttributedString {
      if (surname?.count ?? 0) + (name?.count ?? 0) == 0 {
         let text: NSMutableAttributedString = .init(string: "")
         text.append(theme.colored(Design.color.text))
         text.append(Design.text.fromLowercase.colored(Design.color.text))
         text.append(tgName.string.colored(Design.color.textBrand))
         return text
      }
      let text: NSMutableAttributedString = .init(string: "")
      text.append(theme.colored(Design.color.text))
      text.append(Design.text.fromLowercase.colored(Design.color.text))
      text.append(" ".colored(Design.color.text))
      text.append(name.string.colored(Design.color.textBrand))
      return text
   }
   func forTextForReactionCommendReport(showname: String, notificationType: NotificationType, forWhat: NotificationForWhat) -> NSMutableAttributedString {
      let text: NSMutableAttributedString = .init(string: "")
      switch notificationType {
      case .commentAdded:
         text.append(Design.text.newComment.colored(Design.color.text))
      case .likeAdded:
         text.append(Design.text.newReaction.colored(Design.color.text))
      case .newReportToChallenge:
         text.append(Design.text.newReport.colored(Design.color.text))
      case .transactAdded, .challengeCreated, .challengeWin, .marketplace, .challengeFinished, .questionnaire:
         break
      }
      
      switch forWhat {
      case .transaction:
         text.append(Design.text.forTransaction.colored(Design.color.text))
      case .challenge:
         text.append(Design.text.forChallenge.colored(Design.color.text))
      }
      
      text.append(Design.text.fromSpaceAfter.colored(Design.color.text))
      text.append(showname.colored(Design.color.textBrand))
      return text
   }
}

final class NotificationsCellModel<Design: DSP>:
   Stack<WrappedX<ImageViewModel>>.Right<LabelModel>
   .Down<LabelModel>.Ninja,
   //
   Designable
{
   //
   var iconPlace: StackModel { models.main }
   var icon: ImageViewModel { models.main.subModel }
   var date: LabelModel { models.right }
   var type: LabelModel { models.down }

   private lazy var typeIcon = ImageViewModel()
      .size(.square(13))

   private lazy var typeIconWrapper = WrappedX(typeIcon)
      .backColor(Design.color.background)
      .cornerCurve(.continuous).cornerRadius(21/2)
      .size(.square(21))
      .alignment(.center)
      .distribution(.equalCentering)

   required init() {
      super.init(isAutoreleaseView: true)

      setAll { icon, date, notify in
         //
         icon
            .size(.square(36))
            .cornerCurve(.continuous).cornerRadius(36/2)
         //
         date
            .set(Design.state.label.regular12Secondary)
         //
         notify
            .set(Design.state.label.regular12)
            .numberOfLines(2)
            .lineBreakMode(.byWordWrapping)
      }

      iconPlace
         .addModel(typeIconWrapper) { anchors, view in
            anchors
               .centerX(view.centerXAnchor, 36/3)
               .centerY(view.centerYAnchor, -36/3)
         }

      padding(.outline(16))
      spacing(12)
      height(76)
   }
}

extension NotificationsCellModel: SetupProtocol {
   func setup(_ data: Notification) {
//
      icon
         .image(Design.icon.anonAvatar)
         .imageTintColor(Design.color.iconBrand)
      date.text(data.updatedAt?.timeAgoConverted ?? "")
      type.text(data.theme)

      switch data.type {
      case .transactAdded:
         let tgName = data.transactionData?.senderTgName
         let amount = Int(data.transactionData?.amount ?? 0)
         let amountText = Design.text.pluralCurrencyWithValue(amount, case: .accusative)
         var text = ""
         if data.transactionData?.senderId == nil {
            text = Design.text.youReceived + amountText
         } else {
            text = Design.text.youReceived + amountText + Design.text.fromLowercase + tgName.string
         }
         type.text(text)
         typeIcon.image(Design.icon.tablerBrandTelegram)
      case .commentAdded:
         typeIcon.image(Design.icon.tablerMessageCircle)
         let surname = data.commentData?.commentFromSurname
         let name = data.commentData?.commentFromFirstName
         let tgName = data.commentData?.commentFromTgName
         let text = formTextForNotification(theme: data.theme,
                                            name: name, surname:
                                             surname,
                                            tgName: tgName)
         type.text(text)
      case .likeAdded:
         typeIcon.image(Design.icon.like)
         let surname = data.likeData?.reactionFromSurname
         let name = data.likeData?.reactionFromFirstName
         let tgName = data.likeData?.reactionFromTgName
         let text = formTextForNotification(theme: data.theme,
                                            name: name,
                                            surname: surname,
                                            tgName: tgName)
         type.text(text)
      case .challengeWin:
         let challengeName = data.winnerData?.challengeName
         let text = data.theme + " " + challengeName.string
         type.text(text)
         typeIcon.image(Design.icon.tablerMessageCircle)
      case .newReportToChallenge:
         let surname = data.reportData?.reportSenderSurname
         let name = data.reportData?.reportSenderFirstName
         let tgName = data.reportData?.reportSenderTgName
         let text = formTextForNotification(theme: data.theme,
                                            name: name,
                                            surname: surname,
                                            tgName: tgName)
         type.text(text)
         typeIcon.image(Design.icon.tablerUserCheck)
      case .challengeCreated:
         typeIcon.image(Design.icon.tablerMoodSmile)
      case .challengeFinished:
         typeIcon.image(Design.icon.tablerMoodSmile)
      case .marketplace:
         let offerName = data.orderData?.offerName ?? ""
         let customerName = data.orderData?.customerName ?? ""
         let marketplaceName = data.orderData?.marketplaceName ?? ""
         type.text(data.theme + " " + offerName + " от " + customerName + " в " + marketplaceName)
         typeIcon.image(Design.icon.tablerGift)
      case .questionnaire:
         var text = ""
         if let mode = data.questionnaireData?.mode {
            switch mode {
            case 1:
               text = Design.text.surveyFinished
            case 2:
               text = Design.text.surveyClosesTomorrow
            case 3:
               text = Design.text.surveyClosesTomorrow
            case 4:
               text = Design.text.newSurvey
            default:
               text = Design.text.surveyFinished
            }
         }
         type.text(text)
         break
      case .none:
         break
      }
   }
   
   func formTextForNotification(theme: String, name: String?, surname: String?, tgName: String?) -> String {
      if (surname?.count ?? 0) + (name?.count ?? 0) == 0 {
         let text = theme + Design.text.fromLowercase + tgName.string
         return text
      }
      let text = theme + Design.text.fromLowercase + surname.string + " " + name.string
      return text
   }
}
