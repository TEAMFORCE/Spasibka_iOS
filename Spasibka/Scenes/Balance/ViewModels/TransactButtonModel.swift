//
//  TransactButtonModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 05.12.2023.
//

import StackNinja
import UIKit

final class TransactButtonModel<Design: DSP>: Stack<ImageViewModel>.D<LabelModel>.D2<Spacer>.Ninja,
   ModableStackButtonModelProtocol,
   Designable
{
   typealias State = StackState
   typealias State2 = ButtonState

   var modes: ButtonMode = .init()
   var events: EventsStore = .init()

   required init() {
      super.init()

      setAll { image, label, _ in
         image
            .size(.square(48))
            .cornerCurve(.continuous).cornerRadius(48 / 2)
            .contentMode(.scaleAspectFill)
            .backColor(Design.color.backgroundSecondary)

         label
            .alignment(.center)
            .set(Design.state.label.regular12)
            .numberOfLines(1)
      }
      alignment(.center)
      height(70)
      spacing(4)


      view.startTapGestureRecognize()
      view.on(\.didTap, self) {
         self.view.animateTap(uiView: self.view)
         $0.send(\.didTap)
      }
   }
}

enum TransactButtonState {
   case text(String)
   case image(UIImage)
   case imageUrl(String)
}

extension TransactButtonModel: StateMachine {
   func setState(_ state: TransactButtonState) {
      switch state {
      case let .text(text):
         models.down
            .text(text)
            .kerning(-0.66)
      case let .image(image):
         models.main.image(image)
      case let .imageUrl(url):
         models.main.url(url, placeHolder: Design.icon.avatarPlaceholder.insetted(6))
      }
   }
}

final class ProfileButtonModel<Design: DSP>: Stack<ImageViewModel>.R<LabelModel>.R2<Spacer>.Ninja,
   ModableStackButtonModelProtocol,
   Designable
{
   typealias State = StackState
   typealias State2 = ButtonState

   var modes: ButtonMode = .init()
   var events: EventsStore = .init()

   required init() {
      super.init()

      setAll { image, label, _ in
         image
            .size(.square(48))
            .cornerCurve(.continuous).cornerRadius(48 / 2)
            .contentMode(.scaleAspectFill)
            .backColor(Design.color.backgroundSecondary)

         label
            .alignment(.left)
            .set(Design.state.label.descriptionRegular16)
            .numberOfLines(2)
      }
      alignment(.center)
      height(70)
      spacing(9)


      view.startTapGestureRecognize()
      view.on(\.didTap, self) {
         self.view.animateTap(uiView: self.view)
         $0.send(\.didTap)
      }
   }
   
   func setName(name: String) {
      let attrs = [NSAttributedString.Key.font : Design.font.descriptionRegular16]
      let attributedString = NSMutableAttributedString(string:"\(Design.text.hello)\n",
                                                       attributes:attrs as [NSAttributedString.Key : Any])
      let attrs2 = [NSAttributedString.Key.font : Design.font.descriptionMedium16]
      let nameString = NSMutableAttributedString(string: name,
                                                 attributes:attrs2 as [NSAttributedString.Key : Any])
      attributedString.append(nameString)
      
      models.right.attributedText(attributedString)
   }
}

enum ProfileButtonState {
   case text(String)
   case image(UIImage)
   case imageUrl(String)
}

extension ProfileButtonModel: StateMachine {
   func setState(_ state: ProfileButtonState) {
      switch state {
      case let .text(text):
         models.right
            .text(text)
            .kerning(-0.66)
      case let .image(image):
         models.main.image(image)
      case let .imageUrl(url):
         models.main.url(url, placeHolder: Design.icon.avatarPlaceholder.insetted(6))
      }
   }
}
