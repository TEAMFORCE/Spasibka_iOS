//
//  ChallResultsPresenters.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 14.10.2022.
//

import StackNinja
import UIKit

class ChallResultsPresenters<Design: DesignProtocol>: Designable {
   var events: EventsStore = .init()
   
   var resultsCellPresenter: CellPresenterWork<ChallengeResult, WrappedX<StackModel>> {
      CellPresenterWork { work in
         let result = work.unsafeInput.item
         let updatedAt = result.updatedAt
         let text = result.text.unwrap
         let status = result.status
         
         let textLabel = LabelModel()
            .text(text)
            .numberOfLines(0)
            .set(Design.state.label.regular12)
         
         let statusLabel = LabelModel()
            .text(status)
            .numberOfLines(0)
            .set(Design.state.label.regular12)
            .backColor(Design.color.backgroundInfoSecondary)
         
         let updateAtLabel = LabelModel()
            .text(updatedAt.dateFullConverted)
            .set(Design.state.label.regular12)
         
         let photosPanel = PhotosGalleryMini<Design>().hidden(true)
         photosPanel.setNeedsStoreModelInView()
         if let photos = result.photos {
            photosPanel.hidden(false)
            photos.forEach {
               let photoURL = SpasibkaEndpoints.convertToImageUrl($0)
               photosPanel.addPhoto(url: photoURL)
            }
         } else if let photoLink = result.photo {
            let imageUrl = SpasibkaEndpoints.convertToImageUrl(photoLink)
            photosPanel.addPhoto(url: imageUrl)
            photosPanel.hidden(false)
         }
         
         photosPanel.on(\.didTapImageUrlString, self) {
            $0.send(\.presentImage, $1.0)
         }
            
         let upperStack = StackModel()
            .axis(.horizontal)
            .alignment(.leading)
            .distribution(.fill)
            .spacing(20)
            .arrangedModels([
               statusLabel,
               updateAtLabel.righted()
            ])
         
         let awardLabel = LabelModel()
            .text(Design.text.yourPrize)
            .numberOfLines(1)
            .set(Design.state.label.medium16)
         
         let recievedStack = StackModel()
            .padding(Design.params.cellContentPadding)
            .spacing(Grid.x12.value)
            .alignment(.leading)
            .arrangedModels([
               awardLabel
            ])
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            .backColor(Design.color.background)
            .shadow(Design.params.cellShadow)
            .hidden(true)
         
         if status == "Получено вознаграждение" {
            if let received = result.received {
               awardLabel.text("\(Design.text.yourPrize) \(received)")
               recievedStack.hidden(false)
            }
         }
         
         let cellStack = StackModel()
            .padding(Design.params.cellContentPadding)
            .spacing(Grid.x12.value)
            .alignment(.fill)
            .arrangedModels([
               upperStack.lefted(),
               textLabel,
               photosPanel
            ])
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            .backColor(Design.color.background)
            .shadow(Design.params.cellShadow)
         
         let finalCell = WrappedX(
            StackModel()
               //.padding(Design.params.cellContentPadding)
               .spacing(Grid.x12.value)
               .alignment(.fill)
               .arrangedModels([
                  cellStack,
                  recievedStack
               ])
               .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
               .backColor(Design.color.background)
         )
         .padding(.verticalOffset(Grid.x6.value))
         .padHorizontal(Design.params.commonSideOffset)

         work.success(result: finalCell)
      }
   }
}

extension ChallResultsPresenters: Eventable {
   struct Events: InitProtocol {
      var presentImage: String?
   }
}
