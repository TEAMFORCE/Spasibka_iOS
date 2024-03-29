//
//  TransactionStatusViewModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 02.08.2022.
//

import StackNinja
import UIKit

struct StatusViewInput {
   var sendCoinInfo: SendCoinRequest
   var username: String
   var foundUser: FoundUser
}

struct TransactionStatusViewEvents: InitProtocol {
   var hide: Void?
   var finished: Void?
   var resend: Void?
}

final class TransactionStatusViewModel<Design: DSP>: BaseViewModel<StackViewExtended>,
   Eventable,
   Stateable2,
   Designable
{
   typealias State = StackState
   typealias State2 = ViewState

   typealias Events = TransactionStatusViewEvents
   var events = EventsStore()

   private lazy var image: ImageViewModel = .init()
      .size(.init(width: 275, height: 275))
      .image(Design.icon.transactSuccess)
      .contentMode(.scaleAspectFit)

   private lazy var recipientCell = Design.model.transact.recipientCell

   let button = Design.button.default
      .set(.title(Design.text.toTheBeginingButton))
   let resendButton = Design.button.default
      .set(.title(Design.text.sendTransactionAgain))

   override func start() {
      set(Design.state.stack.default)
      backColor(Design.color.background)
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadius)
      alignment(.fill)

      set(.arrangedModels([
         Spacer(20),
         image,
         Spacer(20),
         recipientCell,
         Spacer(),
         button,
         Spacer(5),
         resendButton
      ]))
      .on(\.hide) { [weak self] in
         self?.hide()
      }

      button.on(\.didTap) {
         self.hide()
      }
      
      resendButton.on(\.didTap) {
         self.resend()
      }
   }

   func setup(info: SendCoinRequest, username: String, foundUser: FoundUser) {
      var userIconText = ""

      if let nameFirstLetter = foundUser.name.unwrap.first,
         let surnameFirstLetter = foundUser.surname.unwrap.first
      {
         userIconText = String(nameFirstLetter) + String(surnameFirstLetter)
      }

      recipientCell.setAll { avatar, userName, nickName, amount in

         if let urlSuffix = foundUser.photo, urlSuffix.count != 0 {
            avatar.url(SpasibkaEndpoints.urlBase + urlSuffix)
         } else {
            print("icon text \(userIconText)")
            let image = userIconText.drawImage(backColor: Design.color.backgroundBrand)
            avatar
               .backColor(Design.color.backgroundBrand)
               .image(image)
         }

         userName
            .text(foundUser.name.unwrap + " " + foundUser.surname.unwrap)
         nickName
            .text("@" + foundUser.tgName.unwrap)
         amount.label
            .text(info.amount)
         amount.models.right2
            .image(Design.icon.logoCurrencyRed)
            .imageTintColor(Design.color.iconError)
      }
   }
}

extension TransactionStatusViewModel {
   private func hide() {
      send(\.finished)
   }
   private func resend() {
     // send(\.finished)
      send(\.resend)
   }
}
