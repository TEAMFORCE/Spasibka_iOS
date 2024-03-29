//
//  Scenes.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.09.2022.
//

import StackNinja

// MARK: - Transact models

protocol TransactModelBuilder: InitProtocol, Designable {
   //
   var balanceInfo: StackNinja<SComboMDR<LabelModel, CurrencyLabelDT<Design>, CurrencyLabelDT<Design>>> { get }
   var userSearchTextField: TextFieldModel { get }
   var searchModel: WrappedX<M<TextFieldModel>.R<ButtonModel>.Ninja> { get }
   var reasonInputTextView: TextViewModel { get }
   var amountIputViewModel: TransactInputViewModel<Design> { get }
   var sendButton: ButtonModel { get }
   var addPhotoButton: ButtonModel { get }
   var addStickerButton: ButtonModel { get }
//   var foundUsersList: StackItemsModel { get }
   var pickedImagesPanel: PickedImagePanel<Design> { get }
   var userNotFoundInfoBlock: Wrapped2Y<ImageViewModel, LabelModel> { get }
   var transactOptionsBlock: TransactOptionsVM<Design> { get }
   var recipientCell: SendCoinRecipentCell<Design> { get }
   //
   var transactSuccessViewModel: TransactionStatusViewModel<Design> { get }
}

struct TransactBuilder<Design: DSP>: TransactModelBuilder {
   //
   var reasonInputTextView: TextViewModel { .init()
      .set(Design.state.label.descriptionRegular14)
      .padding(Design.params.textViewPadding)
      .placeholderColor(Design.color.textFieldPlaceholder)
      .textColor(Design.color.text)
      .backColor(Design.color.background)
      .borderColor(Design.color.boundary)
      .borderWidth(Design.params.borderWidth)
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadiusMini)
      .scrollEnabled(false)
   }

   var userSearchTextField: TextFieldModel { .init()
      .set(Design.state.textField.default)
      .placeholder(Design.text.chooseRecipient)
      .placeholderColor(Design.color.textFieldPlaceholder)
      .disableAutocorrection()
   }
   
   var searchModel = WrappedX<M<TextFieldModel>.R<ButtonModel>.Ninja>()
      .padding(.bottom(12))
      .spacing(20)
      .setup {
         $0.subModel
            .setAll { textField, button in
               textField
                  .placeholder(Design.text.chooseRecipient)
                  .placeholderColor(Design.color.textContrastSecondary)
                  .font(Design.font.descriptionRegular14)
                  .textColor(Design.color.text)
                  
               button
                  .image(Design.icon.searchIcon.withTintColor(Design.color.text))
                  .size(.square(18))
            }
            .height(48)
            .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadiusSmall)
            .borderColor(Design.color.iconMidpoint)
            .borderWidth(1)
            .padding(.outline(12))
      }

   var balanceInfo: Stack<LabelModel>.D<CurrencyLabelDT<Design>>.R<CurrencyLabelDT<Design>>.Ninja { .init()
      .setAll { title, distrAmount, incomeAmount in
         title
            .set(Design.state.label.regular12)
            .height(Grid.x20.value)
            .text(Design.text.availableCurrency)
            .textColor(Design.color.iconInvert)
         distrAmount.currencyLogo
            .width(Grid.x20.value)
            .imageTintColor(Design.color.frameCellBackground)
         distrAmount.label
            .textColor(Design.color.frameCellBackground)
         incomeAmount.currencyLogo
            .width(Grid.x20.value)
            .imageTintColor(Design.color.frameCellBackgroundSecondary)
         incomeAmount.label
            .textColor(Design.color.frameCellBackgroundSecondary)
      }
      .alignment(.leading)
      .height(Grid.x90.value)
      .backColor(Design.color.iconContrast.lightenColor(0.2))
      .cornerCurve(.continuous)
      .cornerRadius(Design.params.cornerRadius)
      .padding(Design.params.infoFramePadding)
      .clipsToBound(true)
      
      .backViewModel(ChostBackLogo<Design>(size: 104)
         .padding(.shift(.init(x: 150.aspected, y: 0)))
         .setup {
            $0.logo.backColor(.black)
         }
         .alpha(0.2)
      )
   }

   var amountIputViewModel: TransactInputViewModel<Design> { .init() }

   var sendButton: ButtonModel { .init()
      .set(Design.state.button.inactive)
      .title(Design.text.sendButton)
   }

   var addPhotoButton: ButtonModel { .init()
      .set(Design.state.button.brandOutline)
      .title(Design.text.addPhoto)
      .textColor(Design.color.text)
      .image(Design.icon.attach.withTintColor(Design.color.iconBrand))
   }

   var addStickerButton: ButtonModel { .init()
      .title(Design.text.addSticker)
      .image(Design.icon.tablerMoodSmile.withTintColor(Design.color.iconInvert))
      .imageInset(.right(28))
      .set(Design.state.button.default)
   }

//   var foundUsersList: StackItemsModel { .init()
//      .set(.activateSelector)
//      .hidden(true)
//      .set(.presenters([
//         TransactBuilder.foundUserPresenter,
//      ]))
//   }

   var pickedImagesPanel: PickedImagePanel<Design> { .init() }

   var userNotFoundInfoBlock: Wrapped2Y<ImageViewModel, LabelModel> {
      Wrapped2Y(
         ImageViewModel()
            .image(Design.icon.userNotFound)
            .size(.square(275)),
         Design.label.medium16
            .numberOfLines(0)
            .alignment(.center)
            .text(Design.text.userNotFound)
      )
   }

   var transactOptionsBlock: TransactOptionsVM<Design> { .init() }

   var recipientCell: SendCoinRecipentCell<Design> { .init() }

   var transactSuccessViewModel: TransactionStatusViewModel<Design> { .init() }

   // MARK: - Private

   static var foundUserPresenter: CellPresenterWork<FoundUser, WrappedY<ImageLabelLabelMRD>> {
      CellPresenterWork<FoundUser, WrappedY<ImageLabelLabelMRD>>() { work in
         let user = work.unsafeInput.item

         let name = user.name
         let surname = user.surname
         let thName = "@" + user.tgName.unwrap

         let comboMRD =
            WrappedY(
               ImageLabelLabelMRD()
                  .setAll { avatar, username, nickname in
                     avatar
                        .image(Design.icon.avatarPlaceholder)
                        .contentMode(.scaleAspectFill)
                        .size(.square(Grid.x32.value))
                        .cornerCurve(.continuous).cornerRadius(Grid.x32.value / 2)
                        .borderColor(Design.color.infoSecondary)
                        .borderWidth(0.5)
                     if let photo = user.photo, photo.count > 7 {
                        let urlString = SpasibkaEndpoints.urlBase + photo
                        avatar.url(urlString)
                     } else {
                        if let nameFirstLetter = user.name.unwrap.first,
                           let surnameFirstLetter = user.surname.unwrap.first
                        {
                           let text = String(nameFirstLetter) + String(surnameFirstLetter)
                           let image = text.drawImage(backColor: Design.color.backgroundBrand)
                           avatar
                              .backColor(Design.color.backgroundBrand)
                              .image(image)
                        } 
                     }
                     if name.unwrap.isEmpty, surname.unwrap.isEmpty {
                        username
                           .size(.init(width: 0, height: 0))
                     } else {
                        username
                           .set(Design.state.label.labelRegular14)
                           .text("\(name.unwrap) \(surname.unwrap)")
                           .textColor(Design.color.text)
                           .padLeft(Grid.x14.value)
                           .height(Grid.x24.value)
                     }
                     
                     nickname
                        .set(Design.state.label.descriptionMedium12)
                        .textColor(Design.color.success)
                        .text(thName)
                        .padLeft(Grid.x14.value)
                  }
                  .padding(Design.params.cellContentPadding)
                  .alignment(.center)
                  .backColor(Design.color.background)
                  .shadow(Design.params.newCellShadow)
                  .height(68)
                  .cornerCurve(.continuous).cornerRadius(Design.params.cornerRadius)
                  .zPosition(1000)
            )
            .padding(.outline(4))

         work.success(result: comboMRD)
      }
   }
}

class ImageLabelLabelMRD: StackNinja<SComboMRD<ImageViewModel, LabelModel, LabelModel>> {
   var image: ImageViewModel { models.main }
   var firstlLabel: LabelModel { models.right }
   var secondLabel: LabelModel { models.down }
}
