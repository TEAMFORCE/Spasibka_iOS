//
//  TextFieldStateBuilder.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.08.2022.
//

import UIKit
import StackNinja

protocol TextFieldElements: InitProtocol, DesignElementable {
   var `default`: DesignElement { get }
   var invisible: [TextFieldState] { get }
}

protocol TextFieldStateProtocol: TextFieldElements where DesignElement == [TextFieldState] {}

struct TextFieldStateBuilder<Design: DSP>: TextFieldStateProtocol, Designable {
   var `default`: [TextFieldState] {[
      .padding(Design.params.contentPadding),
      .placeholder(""),
      .placeholderColor(Design.color.textFieldPlaceholder),
      .font(Design.font.descriptionRegular14),
      .backColor(Design.color.textFieldBack),
      .height(Design.params.buttonHeight),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadiusMini),
      .borderWidth(Design.params.borderWidth),
      .borderColor(Design.color.boundary),
      .textColor(Design.color.text),
      .clearButtonTintColor(Design.color.iconMidpoint)
   ]}

   var invisible: [TextFieldState] {[
      .padding(.init(top: 0, left: 0, bottom: 0, right: 0)),
      .placeholder(""),
      .placeholderColor(Design.color.textFieldPlaceholder),
      .font(Design.font.descriptionRegular14),
      .backColor(Design.color.transparent),
      .height(Design.params.buttonHeight),
      .textColor(Design.color.text),
      .clearButtonTintColor(Design.color.iconMidpoint)
   ]}
}
