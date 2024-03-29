//
//  TransactInfoBlockVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.02.2023.
//

import Alamofire
import StackNinja

final class TransactInfoBlockVM<Asset: ASP>: StackModel, Assetable {
   private var transaction: Transaction?

   private lazy var reasonLabel = SettingsTitleBodyDT<Design>()
      .setAll {
         $0
            .text(Design.text.message)
            .set(Design.state.label.medium16)
         $1
            .set(Design.state.label.regular12)
      }

   private lazy var statusLabel = SettingsTitleBodyDT<Design>()
      .setAll {
         $0
            .text(Design.text.gratitudeStatus)
            .set(Design.state.label.medium16)
         $1
            .set(Design.state.label.regular12)
      }

   lazy var transactPhoto = PhotosGalleryMini<Design>().hidden(true)
      
   lazy var sticker = StackNinja<SComboMD<LabelModel, ImageViewModel>>()
      .setAll {
         $0
            .padBottom(10)
            .set(Design.state.label.medium16)
            .text(Design.text.sticker)
         $1
            .image(Design.icon.transactSuccess)
            .height(130)
            .width(130)
            .contentMode(.scaleAspectFill)
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
      }
      .hidden(true)

   // MARK: - Funcs

   override func start() {
      super.start()

      arrangedModels([
         LabelModel()
            .text(Design.text.information)
            .set(Design.state.label.regular12Secondary),
         reasonLabel,
         statusLabel,
         transactPhoto,
         sticker,
      ])
      distribution(.fill)
      alignment(.fill)
      backColor(Design.color.backgroundInfoSecondary)
      padding(.init(top: 16, left: 16, bottom: 16, right: 16))
      cornerRadius(Design.params.cornerRadiusSmall)
      cornerCurve(.continuous)
      spacing(12)
   }
}

extension TransactInfoBlockVM: StateMachine {
   func setState(_ state: TransactDetailsState) {
      var input: Transaction

      switch state {
      case let .sentTransaction(value):
         input = value
      case let .recievedTransaction(value):
         input = value

         statusLabel
            .models.main.text(Design.text.gratitudeType)
         statusLabel
            .models.down.text(Design.text.incomingGratitude)
      }

      transaction = input
      var textColor = Design.color.text

      switch input.transactionStatus?.id {
      case "A":
         textColor = Design.color.textSuccess
      case "D":
         textColor = Design.color.boundaryError
         statusLabel.models.main.text(Design.text.rejectionReason)
      case "W":
         textColor = Design.color.textWarning
      default:
         textColor = Design.color.text
      }

      statusLabel.models.down.set(.textColor(textColor))
      statusLabel.models.down.text(input.transactionStatus?.name ?? "")

      if let reason = input.reason, reason != "" {
         reasonLabel.models.down.text(reason)
         reasonLabel.hidden(false)
      } else {
         reasonLabel.hidden(true)
      }
      
      setupPhotosAndStickers(input: input)
   }

   private func setupPhotosAndStickers(input: Transaction) {
      if let photos = input.photos {
         
         photos.forEach { photoLink in
            let url = SpasibkaEndpoints.convertToFullImageUrl(photoLink)
            transactPhoto.addPhoto(url: url)
         }
         
         transactPhoto.on(\.didTapImageUrlString, self) {
            Asset.router?.route(
               .presentModallyOnPresented(.automatic),
               scene: \.imageViewer,
               payload: ImageViewerInput.urls(photos, current: $1.1 ?? 0),
               finishWork: $0.presentSentTransactDetails
            )
         }
         
         transactPhoto.hidden(false)
      }

      if let stickerLink = input.sticker {
         let stickerUrl = SpasibkaEndpoints.convertToImageUrl(stickerLink)
         AF
            .request(stickerUrl)
            .responseImage { [weak self] response in
               switch response.result {
               case let .success(image):
                  self?.sticker.models.down.image(image)
                  self?.sticker.hidden(false)
                  self?.sticker.models.down.view.startTapGestureRecognize()
                  self?.sticker.models.down.view.on(\.didTap, self) {
                     Asset.router?.route(
                        .presentModallyOnPresented(.automatic),
                        scene: \.imageViewer,
                        payload: ImageViewerInput.image(image),
                        finishWork: $0.presentSentTransactDetails
                     )
                  }
               case .failure:
                  break
               }
            }
      }
   }

   private var presentSentTransactDetails: Work<Void, Void> { .init { [weak self] _ in
      Asset.router?.route(
         .presentModally(.automatic),
         scene: \.sentTransactDetails,
         payload: self?.transaction
      )
   } }
}
