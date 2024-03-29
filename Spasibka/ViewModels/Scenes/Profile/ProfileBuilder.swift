//
//  ProfileBuilder.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 06.09.2022.
//

import Foundation
import StackNinja

protocol ProfileModelBuilder: InitProtocol, Designable {}

extension ProfileModelBuilder {
   var userEditPanel: Stack<ImageViewModel>.R<FullAndNickNameY<Design>>.R2<ButtonModel>.Ninja { .init()
         .setMain { image in
            image
               .image(Design.icon.newAvatar)
               .contentMode(.scaleAspectFill)
               .cornerCurve(.continuous).cornerRadius(52 / 2)
               .set(.size(.square(52)))
         } setRight: { name in
            name.fullName
               .textColor(Design.color.text)
               .padLeft(Grid.x12.value)
               .height(Grid.x24.value)
            name.nickName
               .set(Design.state.label.regular14brand)
               .padLeft(Grid.x12.value)
               .height(Grid.x24.value)
         } setRight2: { button in
            button
               .size(.square(24))
               .image(Design.icon.editCircle)
         }
         .alignment(.center)
         .distribution(.fill)
         .backColor(Design.color.background)
         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
         .padding(Design.params.cellContentPadding)
         .shadow(Design.params.cellShadow)
         .height(76)
   }

   var userPanel: Stack<ImageViewModel>.R<FullAndNickNameY<Design>>.Ninja { .init()
         .setMain { image in
            image
               .image(Design.icon.newAvatar)
               .contentMode(.scaleAspectFill)
               .cornerCurve(.continuous).cornerRadius(32 / 2)
               .size(.square(32))
         } setRight: { name in
            name.fullName
               .padLeft(Grid.x12.value)
            name.nickName
               .padLeft(Grid.x12.value)
         }
         .alignment(.top)
         .distribution(.fill)
         .backColor(Design.color.background)
         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
         .padding(.outline(12))
         .shadow(Design.params.cellShadow)
         .height(66)
   }

   var editPhotoBlock: EditPhotoBlock<Design> { .init() }

   var userNameTitleSubtitle: FullAndNickNameY<Design> { .init() }

   var titledTextField: TitledTextFieldY<Design> { .init()
         .setAll { main, down in
            main
               .alignment(.left)
               .set(Design.state.label.regular12)
               .textColor(Design.color.textSecondary)
            down
               .alignment(.left)
               .set(Design.state.label.regular14)
               .textColor(Design.color.text)
         }
         .borderColor(Design.color.iconMidpoint)
         .borderWidth(1.0)
         .padding(.horizontalOffset(16))
         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
         .alignment(.fill)
         .height(Grid.x48.value)
   }

   var titleBody: TitleSubtitleY<Design> { .init()
         .setAll { main, down in
            main
               .alignment(.left)
               .set(Design.state.label.regular12)
               .textColor(Design.color.textSecondary)
               .padTop(Grid.x8.value)
            down
               .alignment(.left)
               .set(Design.state.label.regular14)
               .textColor(Design.color.text)
               .padBottom(Grid.x8.value)
         }
         .backColor(Design.color.backgroundInfoSecondary)
         .padding(.horizontalOffset(16))
         .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
         .alignment(.fill)
         .height(Grid.x48.value)
   }

   // MARK: - ProfileVM Blocks

   var userBlock: ProfileUserBlock<Design> { .init() }
   var avatarTextBlock: AvatarTextBlock<Design> { .init() }
   var userNameBlock: UserNameBlock<Design> { .init() }
   var userDiagramBlock: TagsPercentBlock<Design> { .init() }
   var userLastRateBlock: UserLastRateBlock<Design> { .init() }
   var userStatusBlock: UserStatusBlock<Design> { .init() }
   var newStatusBlock: NewStatusBlock<Design> { .init() }
   var userContactsBlock: UserContactsBlock<Design> { .init() }
   var userWorkingPlaceBlock: WorkingPlaceBlock<Design> { .init() }
   var userRoleBlock: UserRoleBlock<Design> { .init() }
   var userLocationBlock: UserLocationBlock<Design> { .init() }
}

struct ProfileBuilder<Design: DSP>: ProfileModelBuilder {}

final class EditPhotoBlock<Design: DSP>: Stack<ButtonModel>.R<FullAndNickNameY<Design>>.Ninja, Designable {
   var photoButton: ButtonModel { models.main }
   var fullAndNickName: FullAndNickNameY<Design> { models.right }

   required init() {
      super.init()

      setAll { button, _ in
         button
            .size(.square(Grid.x60.value))
            .image(Design.icon.camera)
            .backImage(Design.icon.newAvatar)
            .contentMode(.scaleAspectFill)
            .cornerCurve(.continuous)
            .cornerRadius(Grid.x60.value / 2)
      }

      alignment(.center)
      spacing(Grid.x16.value)
   }
}



final class UserAvatarVM<Design: DSP>: ImageViewModel, Designable {
   override func start() {
      super.start()

      image(Design.icon.newAvatar)
      contentMode(.scaleAspectFill)
   }
}

extension UserAvatarVM: StateMachine {
   enum ModelState {
      case size(CGFloat)
   }

   func setState(_ state: ModelState) {
      switch state {
      case let .size(value):
         size(.square(value))
         cornerRadius(value / 2)
      }
   }
}

final class FullAndNickNameY<Design: DSP>: Stack<LabelModel>.D<LabelModel>.Ninja, Designable {
   var fullName: LabelModel { models.main }
   var nickName: LabelModel { models.down }

   required init() {
      super.init()

      setAll { fullName, telegram in
         fullName
            .set(Design.state.label.descriptionRegular14)
            .textColor(Design.color.textSecondary)
            // .padLeft(Grid.x12.value)
            .height(18)
         telegram
            .set(Design.state.label.descriptionRegular14)
            //  .padLeft(Grid.x12.value)
            .height(18)
      }
      spacing(6)
   }
}

final class EditStack<Design: DSP>: StackModel, Designable {
   convenience init(title: String, models: [UIViewModel]) {
      self.init()

      arrangedModels(
         [
            LabelModel()
               .text(title)
               .set(Design.state.label.regular10)
               .textColor(Design.color.textSecondary)
               .padBottom(Grid.x8.value),
         ]
            + models
      )

      spacing(8)
      distribution(.equalSpacing)
      alignment(.fill)
   }
}

struct Contacts {
   var name: String?
   var surname: String?
   var middlename: String?
   var email: String?
   var phone: String?
   var telegram: String?
   var status: String?
}
