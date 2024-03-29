//
//  ButtonElements.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.08.2022.
//

import StackNinja
import UIKit

protocol ButtonElements: InitProtocol, DesignElementable {
   var `default`: DesignElement { get }
   var plain: DesignElement { get }
   var transparent: DesignElement { get }
   var inactive: DesignElement { get }
   var selected: DesignElement { get }
   var awaiting: DesignElement { get }
   var secondary: DesignElement { get }
   var brandSecondary: DesignElement { get }
   var brandSecondaryRound: DesignElement { get }
   
   var inactiveComment: DesignElement { get }
   var defaultComment: DesignElement { get }

   var tabBar: DesignElement { get }
   var brandOutline: DesignElement { get }
   var brandTransparent: DesignElement { get }
}

protocol ButtonStateProtocol: ButtonElements where DesignElement == [ButtonState] {}

// MARK: - ButtonStateBuilder

struct ButtonStateBuilder<Design: DesignProtocol>: ButtonStateProtocol {
   var `default`: [ButtonState] { [
      .backColor(Design.color.activeButtonBack),
      .textColor(Design.color.textInvert),
      .tint(Design.color.iconInvert),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .height(Design.params.buttonHeight),
      .enabled(true),
   ] }

   var plain: [ButtonState] { [
      .backColor(Design.color.background),
      .textColor(Design.color.text),
      .tint(Design.color.text),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .height(Design.params.buttonHeight),
      .enabled(true),
   ] }

   var secondary: [ButtonState] { [
      .backColor(Design.color.backgroundInfoSecondary),
      .textColor(Design.color.text),
      .tint(Design.color.iconContrast),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .height(Design.params.buttonHeight),
      .width(Design.params.buttonHeight),
      .enabled(true),
   ] }

   var brandSecondary: [ButtonState] { [
      .backColor(Design.color.backgroundBrandSecondary),
      .textColor(Design.color.textBrand),
      .tint(Design.color.iconBrand),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .height(Design.params.buttonHeight),
      .enabled(true),
   ] }

   var brandSecondaryRound: [ButtonState] { [
      .backColor(Design.color.backgroundBrandSecondary),
      .textColor(Design.color.textBrand),
      .tint(Design.color.iconBrand),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.buttonHeight / 2),
      .height(Design.params.buttonHeight),
      .enabled(true),
   ] }

   var transparent: [ButtonState] { [
      .backColor(Design.color.transparent),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .height(Design.params.buttonHeight),
      .textColor(Design.color.text),
      .enabled(true),
   ] }

   var inactive: [ButtonState] { [
      .backColor(Design.color.inactiveButtonBack),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .height(Design.params.buttonHeight),
      .textColor(Design.color.textInvert),
      .tint(Design.color.iconInvert),
      .enabled(false),
   ] }
   
   var inactiveComment: [ButtonState] { [
//      .backColor(Design.color.inactiveButtonBack),
      .enabled(false),
   ] }
   
   var defaultComment: [ButtonState] { [
//      .backColor(Design.color.activeButtonBack),
      .enabled(true),
   ] }

   var selected: [ButtonState] { [
      .backColor(Design.color.inactiveButtonBack),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .height(Design.params.buttonHeight),
      .textColor(Design.color.textBrand),
      .tint(Design.color.iconBrand),
   ] }

   var awaiting: [ButtonState] { [
      .backColor(Design.color.inactiveButtonBack),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .height(Design.params.buttonHeight),
      .textColor(Design.color.textBrand),
      .tint(Design.color.iconBrand),
   ] }

   var tabBar: [ButtonState] { [
      .font(UIFont.systemFont(ofSize: 12, weight: .medium)),
      .backColor(.black.withAlphaComponent(0.38)),
      .cornerCurve(.continuous),
      .cornerRadius(0),
      .height(56),
      .textColor(.white),
      .enabled(true),
      .tint(.white),
      .vertical(true),
   ] }

   var brandOutline: [ButtonState] { [
      .backColor(Design.color.transparentButtonBack),
      .textColor(Design.color.textBrand),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .borderColor(Design.color.iconBrand),
      .borderWidth(Design.params.borderWidth),
      .tint(Design.color.iconBrand),
      .height(Design.params.buttonHeight),
      .imageInset(.init(top: 14, left: 14, bottom: 14, right: 14)),
      .enabled(true),
   ] }

   var brandTransparent: [ButtonState] { [
      .backColor(Design.color.transparentButtonBack),
      .textColor(Design.color.textBrand),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .tint(Design.color.iconBrand),
      .height(Design.params.buttonHeight),
      .imageInset(.init(top: 14, left: 14, bottom: 14, right: 14)),
      .enabled(true),
   ] }
}

protocol ButtonBuilderProtocol: ButtonElements, Designable where DesignElement == ButtonModel {}

// MARK: - Buttons

final class ButtonBuilder<Design: DesignProtocol>: ButtonBuilderProtocol {
   var plain: ButtonModel {
      .init(Design.state.button.plain)
   }

   var `default`: ButtonModel {
      .init(Design.state.button.default)
   }

   var secondary: ButtonModel {
      .init(Design.state.button.secondary)
   }

   var transparent: ButtonModel {
      .init(Design.state.button.transparent)
   }

   var inactive: ButtonModel {
      .init(Design.state.button.inactive)
   }

   var selected: ButtonModel {
      .init(Design.state.button.selected)
   }

   var awaiting: ButtonModel {
      .init(Design.state.button.selected)
   }

   var tabBar: ButtonModel {
      .init(Design.state.button.tabBar)
   }

   var brandOutline: ButtonModel {
      .init(Design.state.button.brandOutline)
   }

   var brandSecondary: ButtonModel {
      .init(Design.state.button.brandSecondary)
   }

   var brandSecondaryRound: ButtonModel {
      .init(Design.state.button.brandSecondaryRound)
   }

   var brandTransparent: ButtonModel {
      .init(Design.state.button.brandTransparent)
   }
   
   var inactiveComment: ButtonModel {
      .init(Design.state.button.inactiveComment)
   }
   
   var defaultComment: ButtonModel {
      .init(Design.state.button.defaultComment)
   }
}
