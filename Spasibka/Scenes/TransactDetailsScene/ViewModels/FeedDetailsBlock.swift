//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.10.2022.
//

import StackNinja
import Alamofire
import UIKit

final class FeedDetailsBlock<Asset: AssetProtocol>: StackModel, Assetable {
   private lazy var reasonLabel = LabelModel()
      .numberOfLines(0)
      .set(Design.state.label.descriptionRegular12)

   private lazy var hashTagBlock = HashTagsScrollModel<Design>()

   private var imageUrl: String?
   private var stickerImage: UIImage?

   private lazy var transactPhoto = PhotosGalleryMini<Design>()
      .hidden(true)
   
   private lazy var sticker = StackNinja<SComboMD<LabelModel, ImageViewModel>>()
      .setAll {
         $0
            .padBottom(10)
            .set(Design.state.label.labelRegular14)
            .text(Design.text.sticker)
         $1
            .image(Design.icon.transactSuccess)
            .height(130)
            .width(130)
            .contentMode(.scaleAspectFill)
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
      }
      .alignment(.leading)
      .hidden(true)

   lazy var likesAmountLabel = LabelModel()
      .numberOfLines(1)
      .set(Design.state.label.labelRegular10)
      .textColor(Design.color.textContrastSecondary)
      .text(Design.text.liked)
      .makeTappable()
   
   override func start() {
      super.start()

      spacing(18)
      arrangedModels([
         Spacer(8),
         reasonLabel,
         hashTagBlock,
         likesAmountLabel.righted(),
         transactPhoto,
         sticker
      ])
      .padHorizontal(16)

//      transactPhoto.view
//         .startTapGestureRecognize()
//         .on(\.didTap, self) {
//            Asset.router?.route(.presentModally(.automatic), scene: \.imageViewer, payload: ImageViewerInput.url($0.imageUrl ?? ""))
//         }
      
      sticker.view
         .startTapGestureRecognize()
         .on(\.didTap, self) {
            Asset.router?.route(.presentModally(.automatic), scene: \.imageViewer, payload: ImageViewerInput.image($0.stickerImage ?? Design.icon.transactSuccess))
         }
   }
}

extension FeedDetailsBlock: SetupProtocol {
   func setup(_ data: EventTransaction) {
      if let reason = data.reason, reason != "" {
         reasonLabel.text(reason)
      }

      if data.tags?.isEmpty == false {
         hashTagBlock.setup(data.tags)
         hashTagBlock.hidden(false)
      }
      
      setupPhotos(singlePhoto: data.photo, arrayOfPhotos: data.photos)
      
      if let stickerLink = data.sticker {
         let stickerUrl = SpasibkaEndpoints.convertToImageUrl(stickerLink)
         
         AF
            .request(stickerUrl)
            .responseImage { [weak self] response in
               switch response.result {
               case let .success(image):
                  self?.stickerImage = image
                  self?.sticker.models.down.image(image)
                  self?.sticker.hidden(false)
               case .failure:
                  break
               }
            }
      }
      let likeAmount = String(data.likeAmount ?? 0)
      likesAmountLabel.text(Design.text.liked + " " + likeAmount)
   }
   
   func setupContender(_ contender: Contender) {
//      reasonTitle.text(Design.text.reportText)
      if let text = contender.reportText {
         reasonLabel.text(text)
//         reasonStack.hidden(false)
      }
      
      setupPhotos(singlePhoto: contender.reportPhoto, arrayOfPhotos: contender.reportPhotos)
      
      let likeAmount = String(contender.likesAmount ?? 0)
      likesAmountLabel.text(Design.text.liked + " " + likeAmount)
   }
   
   func setupWinner(_ report: ChallengeReport) {
//      reasonTitle.text(Design.text.reportText)
      if let text = report.text {
         reasonLabel.text(text)
//         reasonStack.hidden(false)
      }
      setupPhotos(singlePhoto: report.photo, arrayOfPhotos: report.photos)
      
      let likeAmount = String(report.likesAmount ?? 0)
      likesAmountLabel.text(Design.text.liked + " " + likeAmount)
   }
   
   func setupPhotos(singlePhoto: String?, arrayOfPhotos: [String]?) {
      if let photos = arrayOfPhotos, !photos.isEmpty {
         transactPhoto.clear()
         photos.forEach { photoLink in
            let imageUrl = SpasibkaEndpoints.convertToImageUrl(photoLink)
            transactPhoto.addPhoto(url: imageUrl)
         }
         
         transactPhoto.on(\.didTapImageUrlString, self) {
            Asset.router?.route(
               .presentModally(.automatic),
               scene: \.imageViewer,
               payload: ImageViewerInput.urls(arrayOfPhotos ?? [], current: $1.1 ?? 0)
            )
         }
         
         transactPhoto.hidden(false)
      } else if let photoLink = singlePhoto {
         imageUrl = SpasibkaEndpoints.convertToImageUrl(photoLink)
         transactPhoto.addPhoto(url: imageUrl ?? "")
         transactPhoto.on(\.didTapImageUrlString, self) {
            Asset.router?.route(
               .presentModally(.automatic),
               scene: \.imageViewer,
               payload: ImageViewerInput.url($1.0)
            )
         }
         transactPhoto.hidden(false)
      }
   }
}
