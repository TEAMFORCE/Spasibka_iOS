//
//  ModalDoubleStackModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 08.09.2022.
//

import StackNinja
import UIKit

class ModalDoubleStackModel<Asset: AssetProtocol>: BodyFooterStackModel, Assetable {

   let title = LabelModel()
      .set(Design.state.label.semibold16)
      .alignment(.center)

   let closeButton = ButtonModel()
      .title(Design.text.close)
      .textColor(Design.color.textBrand)

   private(set) lazy var titlePanel = Wrapped3X(
      Spacer(50),
      title,
      closeButton
   )
   .height(64)
   .alignment(.center)
   .distribution(.equalCentering)

   override func start() {
      super.start()
      
      backColor(Design.color.background)
      cornerRadius(Design.params.cornerRadiusBig)
      cornerCurve(.continuous)
      shadow(.init(radius: 50, color: Design.color.iconContrast, opacity: 0.33))
      padding(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))

      axis(.vertical)
      alignment(.fill)
      distribution(.fill)
      arrangedModels([
         titlePanel,
         bodyStack,
         footerStack
      ])
      disableBottomRadius(Design.params.cornerRadiusBig)
   }
}
