//
//  StackStateBuilder.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 13.08.2022.
//

import StackNinja
import UIKit

protocol StackStatesProtocol: InitProtocol, Designable {
   var `default`: [StackState] { get }

   var brandShiftedBodyStack: [StackState] { get }
   var brandShiftedBodyStackNew: [StackState] { get }

   var header: [StackState]  { get }
   var header1: [StackState] { get }

   var bottomPanel: [StackState] { get }
   var bottomShadowedPanel: [StackState] { get }
   var bottomTabBar: [StackState] { get }

   var mainSceneStack: [StackState] { get }
   var mainSceneMainMenuStack: [StackState] { get }
   var bodyStackOutlinePadded: [StackState] { get }

   var inputContent: [StackState] { get }

   var buttonFrame: [StackState] { get }

   var bottomButtonsPanel: [StackState] { get }
}

struct StackStateBuilder<Design: DesignProtocol>: StackStatesProtocol {
   var `default`: [StackState] { [
      .axis(.vertical),
      .spacing(0),
      .alignment(.fill),
      .distribution(.fill),
      .backColor(Design.color.background),
      .padding(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))
   ] }

   var brandShiftedBodyStack: [StackState] { [
      .axis(.vertical),
      .spacing(0),
      .alignment(.fill),
      .distribution(.fill),
      .backColor(Design.color.background),
      .padding(UIEdgeInsets(top: 0, left: 16, bottom: 48, right: 16))
   ] }
   
   var brandShiftedBodyStackNew: [StackState] { [
      .axis(.vertical),
      .spacing(0),
      .alignment(.fill),
      .distribution(.fill),
      .backColor(Design.color.background),
      .padding(UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0))
   ] }

   var header: [StackState] { [
      .axis(.vertical),
      .spacing(0),
      .alignment(.leading),
      .distribution(.fill),
      .padding(.init(top: -40, left: 16, bottom: 0, right: 16)),
      .backColor(Design.color.backgroundBrand)
   ] }
   
   var header1: [StackState] { [
      .axis(.vertical),
      .spacing(0),
      .alignment(.leading),
      .distribution(.fill),
      .padding(.init(top: -60, left: 16, bottom: 0, right: 16)),
      .backColor(Design.color.backgroundBrand)
   ] }

   var bottomPanel: [StackState] { [
      .axis(.vertical),
      .spacing(Design.params.buttonsSpacingY),
      .alignment(.fill),
      .distribution(.fill),
      .backColor(Design.color.background),
      .padding(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
   ] }

   var inputContent: [StackState] { [
      .axis(.horizontal),
      .spacing(10),
      .alignment(.fill),
      .distribution(.fill),
      .backColor(Design.color.background),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadius),
      .borderWidth(Design.params.borderWidth),
      .borderColor(Design.color.boundary),
      .padding(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
   ] }

   var bottomShadowedPanel: [StackState] { [
      .axis(.vertical),
      .alignment(.fill),
      .distribution(.fill),
      .backColor(Design.color.background),
      .padding(UIEdgeInsets(top: 30, left: 16, bottom: 16, right: 16)),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadiusBig),
      .shadow(.init(radius: 8, color: Design.color.iconContrast, opacity: 0.33))
   ] }

   var bottomTabBar: [StackState] { [
      .axis(.horizontal),
      .distribution(.fillEqually),
      .padding(.zero),
      .spacing(0)
   ] }

   var mainSceneStack: [StackState] { [
      .axis(.vertical),
      .alignment(.fill),
      .distribution(.fill),
      .backColor(Design.color.background),
      .padding(.init(top: Design.params.sceneCornerRadius, left: 0, bottom: 16, right: 0)),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.sceneCornerRadius),
      .shadow(.init(radius: 8, color: Design.color.iconContrast, opacity: 0.33))
   ] }
   
   var mainSceneMainMenuStack: [StackState] { [
      .axis(.vertical),
      .alignment(.fill),
      .distribution(.fill),
      .backColor(Design.color.background),
      .padding(UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)),
//      .cornerCurve(.continuous),
//      .cornerRadius(Design.params.sceneCornerRadius),
//      .shadow(.init(radius: 8, color: Design.color.iconContrast, opacity: 0.33))
   ] }

   var bodyStackOutlinePadded: [StackState] { [
      .axis(.vertical),
      .alignment(.fill),
      .distribution(.fill),
      .backColor(Design.color.background),
      .padding(UIEdgeInsets(top: 30, left: 16, bottom: 16, right: 16)),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadiusBig),
      .shadow(.init(radius: 8, color: Design.color.iconContrast, opacity: 0.33))
   ] }

   var buttonFrame: [StackState] { [
     .backColor(Design.color.background),
     .height(Design.params.buttonHeight),
     .cornerCurve(.continuous),
     .cornerRadius(Design.params.cornerRadius),
     .borderWidth(Design.params.borderWidth),
     .borderColor(Design.color.boundary),
     .padding(Design.params.contentPadding)
   ]}

   var bottomButtonsPanel: [StackState] { [
      .axis(.vertical),
      .spacing(8),
      .alignment(.fill),
      .distribution(.equalSpacing),
      .backColor(Design.color.background),
      .padding(UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)),
      .cornerCurve(.continuous),
      .cornerRadius(Design.params.cornerRadiusBig),
      .maskedCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner])
   ] }
}
