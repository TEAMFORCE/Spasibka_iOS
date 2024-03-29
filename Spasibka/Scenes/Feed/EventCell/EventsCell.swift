//
//  EventsCell.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.07.2023.
//

import StackNinja
import UIKit

final class EventsCell<Design: DSP>: Stack<ImageViewModel>.R<EventsCellInfoBlock<Design>>.Ninja {
   var didTapLinkEvent: Out<URL> {
      infoBlock.textLabel.on(\.didTapLink)
   }

   var didTapMessageButtonWork: VoidWork {
      infoBlock.reactionButtons.didTapMessageButtonWork
   }

   var didTapLikeButtonWork: VoidWork {
      infoBlock.reactionButtons.didTapLikeButtonWork
   }
   
   var didTapBirthdayButtonWork: VoidWork {
      infoBlock.birtdayButton.on(\.didTap)
   }

   private var isLikeButtonProcessing = false
   private var isMessageButtonProcessing = false

   private var avatar: ImageViewModel { models.main }
   private var infoBlock: EventsCellInfoBlock<Design> { models.right }

   required init() {
      super.init()

      setAll { avatar, _ in
         avatar
            .circleWithDiameter(36)
            .contentMode(.scaleAspectFill)
            .backColor(Design.color.backgroundSecondary)
      }
      alignment(.top)
      spacing(12)
      padding(.outline(16))

      setNeedsStoreModelInView()

      infoBlock.reactionButtons.didTapLikeButtonWork
         .onSuccess(self) {
            if !$0.isLikeButtonProcessing {
               $0.didTapLikeButtonWork.sendAsyncEvent()
            }
         }
      
      infoBlock.reactionButtons.didTapMessageButtonWork
         .onSuccess(self) {
            $0.didTapMessageButtonWork.sendAsyncEvent()
         }
   }
   
   func hideReactionButtons() {
      infoBlock.reactionButtons.hidden(true)
   }
   
   func showBirthdayButton() {
      infoBlock.birtdayStack.hidden(false)
   }
}

struct EventsCellData {
   let imageUrl: String?
   let imagePlaceholder: UIImage
   let dateText: String?
   let title: String?
   let text: String
   let userLiked: Bool
   let likesAmount: Int
   let commentsAmount: Int
   let tags: [FeedTag]
   let selector: String
   let textIcon: String?
}

enum EventsCellState {
   case data(EventsCellData)
   case likeProcessing
   case liked(Bool)
}

extension EventsCell: StateMachine {
   func setState(_ state: EventsCellState) {
      isLikeButtonProcessing = false
      switch state {
      case let .data(data):
         
         avatar.indirectUrl(data.imageUrl, placeHolder: data.imagePlaceholder)
         infoBlock.titleLabel.text(data.title.unwrap)
         infoBlock.dateLabel.text(data.dateText.unwrap)
         infoBlock.reactionButtons.likeButton.setState(data.userLiked ? .selected : .none)
         infoBlock.reactionButtons.likeButton.amountText = data.likesAmount.toString
         infoBlock.reactionButtons.messageButton.amountText = data.commentsAmount.toString
         infoBlock.hashTagsScroll.setup(data.tags)
         addLinkedText(data.text)
         if data.selector == "P" {
            infoBlock.reactionButtons.hidden(true)
         }
         if data.selector == "T", data.imageUrl == nil, data.textIcon != nil {
            DispatchQueue.global(qos: .background).async {
               let image = data.textIcon.unwrap.drawImage(backColor: Design.color.backgroundBrand)
               DispatchQueue.main.async { [weak self] in
                  self?.avatar
                     .backColor(Design.color.backgroundBrand)
                     .image(image)
               }
            }
         }
      case let .liked(isLiked):
         if isLiked {
            infoBlock.reactionButtons.likeButton.setState(.selected)
         } else {
            infoBlock.reactionButtons.likeButton.setState(.none)
         }
      case .likeProcessing:
         isLikeButtonProcessing = true
//         infoBlock.reactionButtons.likeButton.setState(.loading)
      }
   }

   private func addLinkedText(_ text: String) {
      guard text.isEmpty == false, let textData = text.data(using: .utf8) else {
         infoBlock.textLabel.hidden(true)
         return
      }

      let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
         .documentType: NSAttributedString.DocumentType.html,
         .characterEncoding: String.Encoding.utf8.rawValue,
      ]
      guard let attributedString = try? NSMutableAttributedString(
         data: textData,
         options: options,
         documentAttributes: nil
      ) else { return }

      attributedString.addAttributes(
         [
            .font: Design.font.descriptionRegular12,
            .foregroundColor: Design.color.text,
            .backgroundColor: Design.color.background
         ],
         range: NSRange(location: 0, length: attributedString.length)
      )

      infoBlock.textLabel.view.linkTextAttributes = [
         .underlineColor: Design.color.transparent,
         .foregroundColor: Design.color.textBrand,
      ]

      infoBlock.textLabel
         .attributedText(attributedString)
   }
}
