//
//  CurrencyButtonDT.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 22.08.2022.
//

import UIKit
import StackNinja

extension CurrencyButtonDT {
   static func makeWithValue(_ text: Int) -> Self {
      let button = Self()
      button.currencyValue = text
      button.models.main
         .text(String(text))
      return button
   }
}

final class CurrencyButtonDT<Design: DSP>: CurrencyLabelDT<Design>, Eventable, Modable {

   typealias Events = ButtonEvents
   var events = EventsStore()

   var modes = ButtonMode()

   var currencyValue = 0

   override func start() {
      setAll {
         $0.set(Design.state.label.bold14)
         $1
         $2.width(Grid.x14.value)
      }

      height(Design.params.buttonHeightSmall)
      cornerRadius(Design.params.cornerRadiusMini)
      cornerCurve(.continuous)
      padding(.horizontalOffset(Grid.x10.value))
      onModeChanged(\.normal) { [weak self] in
         self?.backColor(Design.color.backgroundBrandSecondary)
         self?.label.textColor(Design.color.textBrand)
         self?.models.right2.imageTintColor(Design.color.textBrand)
      }
      onModeChanged(\.selected) { [weak self] in
         self?.backColor(Design.color.backgroundBrand)
         self?.label.textColor(Design.color.textInvert)
         self?.models.right2.imageTintColor(Design.color.iconInvert)
      }
      setMode(\.normal)
      view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
   }

   @objc private func didTap() {
      send(\.didTap)
      animateTapWithShadow(uiView: uiView)
   }

   @discardableResult
   func setValue(_ value: Int) -> Self {
      currencyValue = value
      models.main.text(value.toString)
      return self
   }
}

extension NewCurrencyButtonDT {
   static func makeWithValue(_ text: Int) -> Self {
      let button = Self()
      button.currencyValue = text
      button.models.right2
         .text(String(text))
      return button
   }
}

final class NewCurrencyButtonDT<Design: DSP>: NewCurrencyLabelDT<Design>, Eventable, Modable {

   typealias Events = ButtonEvents
   var events = EventsStore()

   var modes = ButtonMode()

   var currencyValue = 0

   override func start() {
      setAll {
         $0
            .size(.init(width: 12.47, height: 10))
            .image(Design.icon.smallSpasibkaLogo)
            .imageTintColor(Design.color.iconInvert)
         $1
            .size(CGSize(width: 8, height: 8))
         $2
            .set(Design.state.label.medium14)
            .text("0")
            .textColor(Design.color.iconInvert)
      }
      spacing(4)

      height(Design.params.buttonHeightSmall)
      cornerRadius(Design.params.cornerRadiusMini)
      cornerCurve(.continuous)
      padding(.horizontalOffset(Grid.x10.value))
      onModeChanged(\.normal) { [weak self] in
         self?.backColor(Design.color.infoSecondary)
         self?.label.textColor(Design.color.textContrastSecondary)
         self?.models.main.imageTintColor(Design.color.textContrastSecondary)
      }
      onModeChanged(\.selected) { [weak self] in
         self?.backColor(Design.color.backgroundBrandSecondary)
         self?.label.textColor(Design.color.textBrand)
         self?.models.main.imageTintColor(Design.color.iconBrand)
      }
      setMode(\.normal)
      view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
   }

   @objc private func didTap() {
      send(\.didTap)
      animateTapWithShadow(uiView: uiView)
   }

   @discardableResult
   func setValue(_ value: Int) -> Self {
      currencyValue = value
      models.right2.text(value.toString)
      return self
   }
}
