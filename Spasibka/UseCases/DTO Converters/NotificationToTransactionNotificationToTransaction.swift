//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.11.2022.
//

struct NotificationToTransaction: Converter {
   static func convert(_ input: Notification) -> Transaction? {
      let notify = input
      guard let transact = input.transactionData else { return nil }

      return Transaction(
         id: transact.transactionId,
         sender: nil,
         senderId: transact.senderId,
         recipient: nil,
         recipientId: transact.recipientId,
         transactionStatus: nil,
         transactionClass: nil,
         expireToCancel: nil,
         amount: transact.amount?.toString,
         canUserCancel: nil,
         tags: nil,
         reasonDef: nil,
         createdAt: notify.createdAt,
         updatedAt: notify.updatedAt,
         reason: nil,
         graceTimeout: nil,
         isAnonymous: nil,
         isPublic: nil,
         photo: nil,
         organization: nil,
         period: nil,
         scope: nil,
         sticker: nil,
         photos: nil
      )
   }
}

