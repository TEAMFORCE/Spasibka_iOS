//
//  CommonModelBuilder.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 02.09.2022.
//

import Foundation
import StackNinja

protocol CommonModelBuilder: InitProtocol, Designable {}

extension CommonModelBuilder {
   var activityIndicator: ActivityIndicator<Design> { .init() }
   var activityIndicatorSpaced: ActivityIndicatorSpacedBlock<Design> { .init() }

   var hereIsEmpty: HereIsEmpty<Design> { .init() }
   var firstComment: FirstComment<Design> { .init() }
   var hereIsEmptySpaced: HereIsEmptySpacedBlock<Design> { .init() }

   var connectionErrorBlock: CommonErrorSpacedBlock<Design> { .init() }
   var systemErrorBlock: SystemErrorBlockVM<Design> { .init() }
   var systemErrorPopup: SystemErrorBlockVM<Design> {
      .init()
         .backColor(Design.color.background)
         .width(300)
         .padding(.outline(32))
         .cornerRadius(Design.params.cornerRadiusBig)
         .cornerCurve(.continuous)
   }

   func systemErrorPopup(title: String, subtitle: String) -> SystemErrorBlockVM<Design> {
      .init()
      .backColor(Design.color.background)
      .width(300)
      .padding(.outline(32))
      .cornerRadius(Design.params.cornerRadiusBig)
      .cornerCurve(.continuous)
      .setup {
         $0.errorBlock.title.text(title)
         $0.errorBlock.subtitle.text(subtitle)
      }
   }

   var imagePicker: ImagePickerViewModel { .init(
      selectPhotoText: Design.text.selectPhoto,
      takePhotoText: Design.text.takePhoto,
      cancelText: Design.text.cancel
   ) }

   var imagePickerExtended: ImagePickerExtendedViewModel { .init(
      selectPhotoText: Design.text.selectPhoto,
      takePhotoText: Design.text.takePhoto,
      cancelText: Design.text.cancel
   ) }

   var bottomPopupPresenter: BottomPopupPresenter { .init() }
   var centerPopupPresenter: CenterPopupPresenter { .init() }
   var topPopupPresenter: TopPopupPresenter { .init() }

   var divider: WrappedX<ViewModel> {
      .init()
         .alignment(.center)
         .height(Grid.x64.value)
         .padding(.horizontalOffset(-Design.params.commonSideOffset))
         .arrangedModels([
            ViewModel()
               .height(Grid.x4.value)
               .backColor(Design.color.iconMidpointSecondary),
         ])
   }

   var filterButton: ButtonSelfModable { ButtonSelfModable()
      .set(Design.state.button.brandSecondaryRound)
      .shadow(Design.params.cellShadow)
      .size(.square(48))
      .image(Design.icon.tablerFilter)
      .onModeChanged(\.normal) {
         $0
            .backColor(Design.color.backgroundBrandSecondary)
            .image(Design.icon.tablerFilter.withTintColor(Design.color.iconBrand))
      }
      .onModeChanged(\.selected) {
         $0
            .backColor(Design.color.backgroundBrand)
            .image(Design.icon.tablerFilter.withTintColor(Design.color.iconInvert))
      }
      .setMode(\.normal)
   }
}

struct CommonBuilder<Design: DSP>: CommonModelBuilder {}
