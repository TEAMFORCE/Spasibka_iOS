//
//  EventButtonModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 05.02.2024.
//

import StackNinja
import UIKit

final class EventButtonModel<Design: DSP>: Stack<HStackModel>.D<Spacer>.D2<HStackModel>.Ninja,
   ModableStackButtonModelProtocol,
   Designable
{
   typealias State2 = ButtonState

   var modes: ButtonMode = .init()
   var events: EventsStore = .init()
   
   var challengeCoverImages = [Design.icon.challengeCover1,
                               Design.icon.challengeCover2,
                               Design.icon.challengeCover3,
                               Design.icon.challengeCover4,
                               Design.icon.challengeCover5]
   
   private lazy var backImage = ImageViewModel()
      .size(.square(82))
      .cornerRadius(Design.params.cornerRadiusSmall)
      .backColor(Design.color.backgroundBrandSecondary)
      .contentMode(.scaleAspectFit)
      .addModel(
         ViewModel()
            .backColor(Design.color.constantBlack)
            .alpha(0.33)
      ) {
         $0.fitToView($1)
      }

   private lazy var textLabel = LabelModel()
      .backColor(Design.color.transparent)
      .set(Design.state.label.descriptionRegular8)
      .set(.alignment(.left))
      .set(.numberOfLines(2))
      .removeTapGestures()
//   let stack = HStackModel()
   private lazy var imageModel = ImageViewModel()
      .size(.square(32))
      .contentMode(.scaleAspectFill)
      .cornerRadius(32 / 2)
      .cornerCurve(.continuous)
      .backColor(Design.color.background)
   required init() {
      super.init()

      setAll { image, _, label in
         image
            .addArrangedModels([
               Grid.xxx.spacer, imageModel
            ])
            .distribution(.fill)
            .alignment(.leading)
//            .size(.square(32))
//            .contentMode(.scaleAspectFill)
//            .cornerRadius(32 / 2)
//            .cornerCurve(.continuous)
//            .backColor(Design.color.background)
            //.alignment(.trailing)

         label
            .addArrangedModels([
               textLabel, Grid.xxx.spacer
            ])
            .distribution(.fill)
            .alignment(.leading)
//            .backColor(Design.color.transparent)
//            .set(Design.state.label.descriptionRegular8)
//            .set(.alignment(.left))
//            .set(.numberOfLines(2))
//            .removeTapGestures()
      }
      height(82)
      width(82)
//      spacing(8)
      padding(.init(top: 5, left: 6, bottom: 9, right: 6))
      backColor(Design.color.backgroundBrandSecondary)
      cornerRadius(Design.params.cornerRadiusSmall)
//      backImage(Design.icon.thanksGroupBack)
      //alignment(.trailing)
      distribution(.fill)

      view.startTapGestureRecognize()
      view.on(\.didTap, self) {
         self.view.animateTap(uiView: self.view)
         $0.send(\.didTap)
      }
   }
}

enum EventButtonState {
   case text(String)
   case image(UIImage)
   case imageUrl(String)
   case setValues(FeedEvent)
}

extension EventButtonModel: StateMachine {
   func setState(_ state: EventButtonState) {
      switch state {
      case let .text(text):
         //models.down2
         textLabel
            .text(text)
      case let .image(image):
        // models.main
         imageModel
            .image(image)
      case let .imageUrl(url):
//         models.main
         imageModel
            .url(url, placeHolder: Design.icon.avatarPlaceholder.insetted(6))
      case let .setValues(event):
         switch event.selector {
         case "T":
            // transactioin
            configureForTransaction(event)
         case "Q":
            // quest, challenge

            imageModel
               .image(Design.icon.medal.withTintColor(Design.color.iconBrand).insetted(6))
               .hidden(true)

            textLabel
               .text(Design.text.newChallenge)
            textLabel
               .textColor(Design.color.textInvert)
            
            if let imageUrl = event.photos?.first {
               backImage.indirectUrl(SpasibkaEndpoints.urlBase + imageUrl) { [weak self] model, _ in
                  model?.contentMode(.scaleAspectFill)
                  self?.hideActivityModel()
               }
               backViewModel(backImage.wrappedX())
            } else {
               let id = event.id % 5
               if let image = challengeCoverImages[safe: id] {
                  backImage
                     .image(image)
                     .contentMode(.scaleAspectFill)
                  backViewModel(backImage.wrappedX())
               }
            }
         case "R":
            backColor(Design.color.backgroundBrand)
            gradient(
               .init(
                  colors: [Design.color.backgroundBrand.withAlphaComponent(0.75), Design.color.backgroundBrandSecondary.withAlphaComponent(0.75)],
                  startPoint: .zero,
                  endPoint: .init(x: 1, y: 1)
               ),
               size: .init(width: 82.aspected, height: 82.aspected)
            )
            clipsToBound(true)
            maskToBounds(true)
            
//            models.main.backColor(Design.color.transparent)
            //models.down2
            textLabel
               .text(Design.text.winningTheChallenge)
            //models.down2
            textLabel
               .textColor(Design.color.textInvert)
            if let imageUrl = event.photos?.first {
               backImage.indirectUrl(SpasibkaEndpoints.urlBase + imageUrl) { [weak self] model, _ in
                  model?.contentMode(.scaleAspectFill)
                  self?.hideActivityModel()
               }
               backViewModel(backImage.wrappedX())
            }
            if let icon = event.icon {
//               models.main
               imageModel
                  .url(SpasibkaEndpoints.urlBase + icon)
            } else {
//               models.main
               imageModel
                  .image(Design.icon.avatarPlaceholder.insetted(6))
            }
         case "P":
            // purchase
            break
         case "B":
            backImage(Design.icon.thanksGroupBack)
            backColor(Design.color.backgroundBrandSecondary)
//            models.main
            imageModel
               .image(Design.icon.cake.withTintColor(Design.color.iconBrand).insetted(6))
            //models.down2
            textLabel
               .text(Design.text.birthday + "!")
         default:
            break
         }
      }
   }
}

extension EventButtonModel {
   private func configureForTransaction(_ event: FeedEvent) {
      if let index = event.text.unwrap.range(of: "<a")?.lowerBound {
         if event.text?.startIndex == index {
            addTextNotMyTransaction(event.text.unwrap)
            if let iconUrl = event.icon {
//               models.main
               imageModel
                  .url(SpasibkaEndpoints.urlBase + iconUrl)
            } else {
//               models.main
               imageModel
                  .image(Design.icon.avatarPlaceholder.insetted(6))
            }
         } else {
            addTextMyTransaction(event.text.unwrap)
         }
      } else {
         addTextMyTransaction(event.text.unwrap)
      }
   }

   private func addTextMyTransaction(_: String) {
      backColor(Design.color.backgroundBrand)
//      models.main
      imageModel
         .image(Design.icon.smallSpasibkaLogo.withTintColor(Design.color.iconBrand).insetted(16))
      //models.down2
      textLabel
         .text(Design.text.newTransactForYou)
      //models.down2
      textLabel
         .textColor(Design.color.textInvert)
      //models.down2.alignment(.left)
   }

   private func addTextNotMyTransaction(_ text: String) {
      if let firstIndex = text.firstIndex(of: ">") {
         if let range = text.range(of: "</a>") {
            let substring = text[firstIndex ..< range.lowerBound]

            var name = substring.dropFirst()
            print(name)
            if name.count > 4 {
               name = name.prefix(4) + "..."
            }

            let prefix = String(text[range.upperBound ..< text.endIndex].dropFirst())
            let arr = prefix.components(separatedBy: " ")
            let infoText: NSMutableAttributedString = .init(string: "")

            infoText.append(String(name + " " + arr[0] + " ").colored(Design.color.text))
            infoText.append(String(arr[1] + " " + arr[2]).colored(Design.color.textBrand))

            infoText.addAttribute(
               .font,
               value: Design.font.descriptionRegular8,
               range: NSRange(location: 0, length: infoText.length)
            )

            //models.down2
            textLabel
               .attributedText(infoText)
            backColor(Design.color.backgroundBrandSecondary)
            backImage(Design.icon.thanksGroupBack)
//            models.main
            imageModel
               .image(Design.icon.avatarPlaceholder.withTintColor(Design.color.iconBrand).insetted(6))
         } else {
            print("String not present")
         }
      }
   }
}
