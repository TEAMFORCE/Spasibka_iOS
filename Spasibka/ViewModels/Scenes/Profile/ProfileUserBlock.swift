//
//  File.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.12.2022.
//

import StackNinja

// MARK: - ProfileUserBlock

final class ProfileUserBlock<Design: DSP>: Stack<UserAvatarVM<Design>>.R<Spacer>.R2<ButtonModel>.Ninja,
                                           Designable
{
   var avatarButton: UserAvatarVM<Design> { models.main }
   var notifyButton: ButtonModel { models.right2 }

   required init() {
      super.init()

      setAll { avatar, _, notifyButton in
         avatar.setState(.size(48))
         notifyButton
            .image(Design.icon.alarm, color: Design.color.iconContrast)
            .size(.square(36))
      }

      alignment(.center)
   }
}

final class AvatarTextBlock<Design: DSP>: Stack<UserAvatarVM<Design>>.R<Spacer>.R2<LabelModel>.Ninja,
                                           Designable
{
   var avatarButton: UserAvatarVM<Design> { models.main }
   var textLabel: LabelModel { models.right2 }

   required init() {
      super.init()

      setAll { avatar, _, textLabel in
         avatar
            .setStates(.size(48))
            .makeTappable()
            .userInterractionEnabled(true)
         textLabel
            .set(Design.state.label.medium24)
            .textColor(Design.color.textSuccess)
      }

      alignment(.center)
   }
}

