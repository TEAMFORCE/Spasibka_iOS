//
//  ParamsProtocol.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.08.2022.
//

import StackNinja
import UIKit

// MARK: - Parameters

protocol ParamsProtocol: InitProtocol, Designable {}

extension ParamsProtocol {
   //
   var commonSideOffset: CGFloat { 16 }
   //
   var cornerRadiusNano: CGFloat { 4.8 }
   var cornerRadiusMini: CGFloat { 8 }
   var cornerRadiusSmall: CGFloat { 12 }
   var cornerRadius: CGFloat { 16 }
   var cornerRadiusBig: CGFloat { 20 }
   //
   var sceneCornerRadius: CGFloat { 31 }
   //
   var borderWidth: CGFloat { 1 }

   var titleSubtitleOffset: CGFloat { 16 }
   var globalTopOffset: CGFloat { 24 }
   //
   var buttonHeight: CGFloat { 52 }
   var buttonHeightSmall: CGFloat { 38 }
   var buttonHeightMini: CGFloat { 28 }
   var buttonHeightMicro: CGFloat { 24 }
   //
   var buttonsSpacingX: CGFloat { 8 }
   var buttonsSpacingY: CGFloat { 16 }
   //
   var infoFrameHeight: CGFloat { 70 }
   //
   var templateCellShadow: Shadow { .init(
      radius: 9,
      offset: .init(x: 0, y: 8),
      color: Design.color.iconContrast,
      opacity: 0.19
   ) }

   var panelShadow: Shadow { .init(
      radius: 20,
      color: Design.color.iconContrast,
      opacity: 0.19
   ) }
   var panelButtonShadow: Shadow { .init(
      radius: 9,
      offset: .init(x: 0, y: 10),
      color: Design.color.iconContrast,
      opacity: 0.19
   ) }
   var panelMainButtonShadow: Shadow { .init(
      radius: 9,
      offset: .init(x: 0, y: 10),
      color: Design.color.iconContrast,
      opacity: 0.23
   ) }
   var cellShadow: Shadow { .init(
      radius: 9,
      offset: .init(x: 0, y: 4),
      color: Design.color.iconContrast,
      opacity: 0.13
   ) }
   var balanceFrameCellShadow: Shadow { .init(
      radius: 100,
      offset: .init(x: 9, y: 0),
      color: .systemRed,
      opacity: 0.5
   ) }
   var profileUserPanelShadow: Shadow { .init(
      radius: 12,
      offset: .init(x: 0, y: 12),
      color: UIColor(red: 0.794, green: 0.816, blue: 0.858, alpha: 0.25), // Design.color.iconContrast,
      opacity: 1.0
   ) }
   
   var newCellShadow: Shadow { .init(
      radius: 8,
      offset: .init(x: 0, y: 7),
//      rgba(138, 138, 138, 0.1)
      color: UIColor(red: 0.542, green: 0.542, blue: 0.542, alpha: 0.15),
      opacity: 1
   ) }
   // paddings
   var contentPadding: UIEdgeInsets { .init(top: 12, left: commonSideOffset, bottom: 12, right: commonSideOffset) }
   var contentVerticalPadding: UIEdgeInsets { .init(top: 12, left: 0, bottom: 12, right: 0) }

   var textViewPadding: UIEdgeInsets {
      .init(top: 12, left: 10, bottom: 12, right: 10)
   }

   var cellContentPadding: UIEdgeInsets { .init(top: 12, left: commonSideOffset, bottom: 12, right: commonSideOffset) }
   var userInfoHeaderPadding: UIEdgeInsets { .init(top: 12, left: 12, bottom: 12, right: 12) }
   var infoFramePadding: UIEdgeInsets { .init(top: 16, left: 24, bottom: 24, right: 24) }
}

struct ParamBuilder<Design: DSP>: ParamsProtocol {}
