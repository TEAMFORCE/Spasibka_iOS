//
//  DiagramProfileVM.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 04.12.2022.
//

import StackNinja

// MARK: - MyProfileVM

final class ProfileVM<Design: DSP>: ScrollStackedModelY, Designable {

   private (set) lazy var eventer = ProfileVMEventer()

   private (set) lazy var userBlock = Design.model.profile.userBlock
   private (set) lazy var avatarTextBlock = Design.model.profile.avatarTextBlock
      .hidden(true)
   private (set) lazy var userNameBlock = Design.model.profile.userNameBlock
   private (set) lazy var diagramBlock = Design.model.profile.userDiagramBlock
      .hidden(true)
      .hideCircularTexts()
   private (set) lazy var userLastRateBlock = Design.model.profile.userLastRateBlock
      .hidden(true)
//   private (set) lazy var userStatusBlock = Design.model.profile.userStatusBlock
//      .hidden(true)
   private (set) lazy var newStatusBlcok = Design.model.profile.newStatusBlock
//      .hidden(true)
   private (set) lazy var userContactsBlock = Design.model.profile.userContactsBlock
      .hidden(true)
   private (set) lazy var workingPlaceBlock = Design.model.profile.userWorkingPlaceBlock
      .hidden(true)
   private (set) lazy var userRoleBlock = Design.model.profile.userRoleBlock
      .hidden(true)
   private (set) lazy var locationBlock = Design.model.profile.userLocationBlock
      .hidden(true)

   override func start() {
      super.start()

      arrangedModels(
         userBlock,
         avatarTextBlock,
         userNameBlock,
//         userStatusBlock,
         newStatusBlcok,
         diagramBlock,
         userLastRateBlock,
         userContactsBlock,
         workingPlaceBlock,
         userRoleBlock,
         locationBlock
      )
      spacing(16)
      padding(.horizontalOffset(16))

      configEvents()
   }

   private func configEvents() {
      userContactsBlock.view
         .startTapGestureRecognize()
         .on(\.didTap, self) {
            $0.eventer.send(\.didTapContacts)
         }

//      locationBlock.view
//         .startTapGestureRecognize()
//         .on(\.didTap, self) {
//            $0.eventer.send(\.didTapLocation)
//         }
   }
}

struct ProfileVMEvents: InitProtocol {
   var didTapContacts: Void?
   var didTapLocation: Void?
}

final class ProfileVMEventer: Eventable {
   typealias Events = ProfileVMEvents

   var events = EventsStore()
}
