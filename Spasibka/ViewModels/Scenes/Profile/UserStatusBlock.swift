//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja

// MARK: - UserStatusBlock

struct StatusBlockEvent: InitProtocol {
   var mainStatus: Void?
   var secondaryStatus: Void?
}

final class NewStatusBlock<Design: DSP>: Stack<UserStatusBlock<Design>>.D<UserStatusBlock<Design>>.Ninja,
                                          Designable, Eventable {
   typealias Events = StatusBlockEvent
   var events: EventsStore = .init()
   
   var mainStatus: UserStatusBlock<Design> { models.main }
   var secondaryStatus: UserStatusBlock<Design> { models.down }

   required init() {
      super.init()
      setAll { mainStatus, secondaryStatus in
         mainStatus.title.text(Design.text.status)
         secondaryStatus.title.text(Design.text.workFormat)
      }
      spacing(20)
      backColor(Design.color.backgroundBrand)
      cornerRadius(Design.params.cornerRadius)
      cornerCurve(.continuous)
      padding(.outline(16))
   }
   
   override func start() {
      mainStatus.on(\.didTap, self) {
         $0.send(\.mainStatus)
      }
      secondaryStatus.on(\.didTap, self) {
         $0.send(\.secondaryStatus)
      }
   }
}

final class UserStatusBlock<Design: DSP>: Stack<LabelModel>.R<LabelModel>.R2<ImageViewModel>.Ninja,
   Designable
{
   var events: EventsStore = .init()

   var chevronIcon: ImageViewModel { models.right2 }
   var title: LabelModel { models.main }

   required init() {
      super.init()

      setAll { title, status, icon in
         title
            .set(Design.state.label.semibold16)
            .textColor(Design.color.textInvert)
            .text(Design.text.status)
         status
            .set(Design.state.label.regular14)
            .alignment(.right)
            .textColor(Design.color.textInvert)
         icon
            .size(.square(16))
            .image(Design.icon.tablerChevronRight, color: Design.color.iconInvert)
      }

//      backColor(Design.color.backgroundBrand)
//      cornerRadius(Design.params.cornerRadius)
//      cornerCurve(.continuous)
//      padding(.outline(16))
   }

   override func start() {
      view.startTapGestureRecognize()
      view.on(\.didTap, self) { $0.send(\.didTap) }
   }
}

extension UserStatusBlock: Eventable {
   typealias Events = TappableEvent
}

extension UserStatusBlock: StateMachine {
   func setState(_ state: String) {
      models.right.text(state)

      hidden(false)
   }
}
