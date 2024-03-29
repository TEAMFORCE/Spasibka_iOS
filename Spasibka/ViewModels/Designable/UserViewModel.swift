//
//  UserViewModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 21.09.2023.
//

import StackNinja

final class UserViewModel<Design: DSP>: Stack<ImageViewModel>.R<LabelModel>.D<LabelModel>.Ninja {
   var avatarImageModel: ImageViewModel { models.main }
   var usernameLabelModel: LabelModel { models.right }
   var captionLabelModel: LabelModel { models.down }

   required init() {
      super.init()

      setAll { avatar, username, caption in
         avatar
            .size(.square(32))
            .cornerRadius(32 / 2)
            .contentMode(.scaleAspectFill)
         username
            .set(Design.state.label.descriptionMedium14)
            .textColor(Design.color.text)
         caption
            .set(Design.state.label.descriptionRegular12)
            .textColor(Design.color.textSecondary)
      }
      padding(.outline(12))
      spacing(12)
      backColor(Design.color.background)
   }
}

struct UserViewModelState {
   let imageUrl: String?
   let name: String?
   let surname: String?
   let caption: String?
}

extension UserViewModel: StateMachine {
   func setState(_ state: UserViewModelState) {
      let nameFirstLetter = state.name?.first?.uppercased()
      let surnameFirstLetter = state.surname?.first?.uppercased()
      if let photoUrl = state.imageUrl {
         avatarImageModel.indirectUrl(photoUrl)
      } else {
         avatarImageModel
            .textImage(
               nameFirstLetter.unwrap + surnameFirstLetter.unwrap,
               backColor: Design.color.backgroundBrand,
               textColor: Design.color.textInvert
            )
      }
      
//         .indirectUrl(state.imageUrl)
      usernameLabelModel.text(state.name.unwrap + " " + state.surname.unwrap)
      captionLabelModel.text(state.caption.unwrap)
   }
}

enum UserCellPresenter<Design: DSP> {
   static var presenter: CellPresenterWork<UserViewModelState, StackModel> { .init { work in
      let item = work.in.item
      
      let viewModel = UserViewModel<Design>()
      viewModel
         .setStates(item)
         .cornerCurve(.continuous)
         .cornerRadius(Design.params.cornerRadiusSmall)
         .shadow(Design.params.cellShadow)
         .setNeedsStoreModelInView()
      
      let cell = viewModel.wrappedX()
         .padHorizontal(Design.params.commonSideOffset)
         .padVertical(4)
      
      work.success(cell)
   }}
}
