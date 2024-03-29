//
//  PageButtonModel.swift
//  Spasibka
//
//  Created by Yerzhan Gapurinov on 05.02.2024.
//

import StackNinja
import UIKit

final class PageButtonModel<Design: DSP>: Stack<LabelModel>.D<ImageViewModel>.Ninja,
   ModableStackButtonModelProtocol,
   Designable
{
   typealias State = StackState
   typealias State2 = ButtonState

   var modes: ButtonMode = .init()
   var events: EventsStore = .init()

   required init() {
      super.init()

      setAll { label, image in
         label
            .alignment(.right)
            .set(Design.state.label.regular12)
            .numberOfLines(1)
         
         image
            .size(.square(90))
            .contentMode(.scaleAspectFill)
            .backColor(Design.color.background)
      }
      minHeight(115)
      width(107)
      spacing(6)
      padding(.init(top: 0, left: 10, bottom: 10, right: 10))
      backColor(Design.color.background)
      cornerRadius(Design.params.cornerRadiusSmall)
      shadow(Design.params.newCellShadow)

      view.startTapGestureRecognize()
      view.on(\.didTap, self) {
         self.view.animateTap(uiView: self.view)
         $0.send(\.didTap)
      }
   }
}

enum PageButtonState {
   case text(String)
   case image(UIImage)
   case imageUrl(String)
}

extension PageButtonModel: StateMachine {
   func setState(_ state: PageButtonState) {
      switch state {
      case let .text(text):
         models.main
            .text(text)
            .kerning(-0.66)
      case let .image(image):
         models.down.image(image)
      case let .imageUrl(url):
         models.down.url(url, placeHolder: Design.icon.avatarPlaceholder.insetted(6))
      }
   }
}
