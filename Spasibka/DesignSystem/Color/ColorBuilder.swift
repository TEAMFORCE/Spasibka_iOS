//
//  Colors.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 12.07.2022.
//

import StackNinja
import UIKit

protocol ColorTokenProtocol {}

// imported from Figma via "Colors to Code" Figma's plugin
enum ColorToken: String, ColorTokenProtocol {
   //

   case brand = "--general-brand"
   case brandSecondary = "--general-brand-secondary"

   case contrast = "--general-contrast"
   case contrastSecondary = "--general-contrast-secondary"

   case negative = "--general-negative"
   case negativeSecondary = "--minor-negative-secondary"

   case midpoint = "--general-midpoint"

   case success = "--minor-success"
   case successSecondary = "--minor-success-secondary"

   case error = "--minor-error"
   case errorSecondary = "--minor-error-secondary"

   case warning = "--minor-warning"
   case warningSecondary = "--minor-warning-secondary"

   case info = "--minor-info"
   case infoSecondary = "--minor-info-secondary"

   case extra1 = "--extra1"
   case extra2 = "--extra2"
}

// Протокол Фабрики цветов
protocol ColorsProtocol: InitProtocol {
   typealias Token = ColorToken
}

// MARK: - Colors implement

extension ColorsProtocol {
   var transparent: UIColor { .clear }

   var text: UIColor { Token.contrast.color }
   var textSecondary: UIColor { Token.contrastSecondary.color }
   var textSecondaryInvert: UIColor { Token.negative.color }
   var textSuccess: UIColor { Token.success.color }
   var textInfo: UIColor { Token.info.color }
   var textThird: UIColor { Token.contrast.color }
   var textThirdInvert: UIColor { Token.negative.color }
   var textInvert: UIColor { Token.negative.color }
   var textError: UIColor { Token.error.color }
   var textWarning: UIColor { Token.warning.color }
   var textContrastSecondary: UIColor { Token.contrastSecondary.color }
   var textBrand: UIColor { Token.brand.color }
   var textMidpoint: UIColor { Token.midpoint.color }

   var background: UIColor { Token.negative.color }
   var backgroundSecondary: UIColor { Token.negativeSecondary.color }
   var backgroundBrand: UIColor { Token.brand.color }
   var backgroundBrandSecondary: UIColor { Token.brandSecondary.color }
   var infoSecondary: UIColor { Token.infoSecondary.color }

   var backgroundInfo: UIColor { Token.info.color }
   var backgroundInfoSecondary: UIColor { Token.infoSecondary.color }
   var backgroundSuccess: UIColor { Token.success.color }
   var backgroundSuccessSecondary: UIColor { Token.successSecondary.color }
   var backgroundError: UIColor { Token.error.color }
   var backgroundErrorSecondary: UIColor { Token.errorSecondary.color }
   var backgroundWarning: UIColor { Token.warning.color }
   var backgroundWarningSecondary: UIColor { Token.warningSecondary.color }

   // button colors
   var activeButtonBack: UIColor { Token.brand.color }
   var inactiveButtonBack: UIColor { Token.brandSecondary.color }
   var transparentButtonBack: UIColor { transparent }

   // textfield colors
   var textFieldBack: UIColor { Token.negative.color }
   var textFieldPlaceholder: UIColor { Token.midpoint.color }

   // boundaries
   var boundary: UIColor { Token.midpoint.color }
   var boundaryError: UIColor { Token.error.color }

   // icons
   var iconContrast: UIColor { Token.contrast.color }
   var iconSecondary: UIColor { Token.contrastSecondary.color }
   var iconMidpoint: UIColor { Token.midpoint.color }
   var iconMidpointSecondary: UIColor { Token.midpoint.color }
   var iconInvert: UIColor { Token.negative.color }
   var iconBrand: UIColor { Token.brand.color }
   var iconBrandSecondary: UIColor { Token.brandSecondary.color }
   var iconWarning: UIColor { Token.warning.color }
   var iconError: UIColor { Token.error.color }

   // Frame cell color
   var frameCellBackground: UIColor { Token.extra1.color }
   var frameCellBackgroundSecondary: UIColor { Token.extra2.color }

   // Tables
   var cellSeparatorColor: UIColor { Token.midpoint.color }

   // success error
   var errorSecondary: UIColor { Token.errorSecondary.color }
   var success: UIColor { Token.success.color }
   var successSecondary: UIColor { Token.successSecondary.color }

   var constantBlack: UIColor { .black }

   // brands
   var brandVKontakte: UIColor { .init("#0077FF") }

   // extra
   var constantWhite: UIColor { .white }
}

// Палитра
struct ColorBuilder: ColorsProtocol {}

// MARK: - Private helpers

import SwiftCSSParser

enum OrganizationColorScheme: Int {
   case spasibka = 1
   case ruDemo = 4
   case ruDemo2 = 69

   func colorScheme() -> String {
      switch self {
      case .spasibka:
         return "CssColors"
      case .ruDemo:
         return "CssColors2"
      case .ruDemo2:
         return "CssColors2"
      }
   }
}

extension ColorToken {
   static func recolor() {
      let colorSchemeName = UserDefaults.standard.loadString(forKey: .colorSchemeKey)
      ?? OrganizationColorScheme.spasibka.colorScheme()

      let str = loadColorsCss(colorSchemeName)
      let colors = parseCssColors(str)
      currentColors = colors
   }

   static func loadColorsFor(_ org: OrganizationColorScheme) -> [ColorToken: UIColor] {
      let str = loadColorsCss(org.colorScheme())
      let colors = parseCssColors(str)
      return colors
   }

   static func brandColorForOrganization(_ org: OrganizationColorScheme) -> UIColor {
      let colors = loadColorsFor(org)
      return colors[.brand] ?? .black
   }
}

// TODO: - Remove previous extensions
extension ColorToken {
   static func updateColorScheme(_ colorsJson: ColorsJSON?) {
      applyDefaultColors()

      currentColors[.brand] = colorsJson?.brand?.toColor ?? currentColors[.brand]
      currentColors[.brandSecondary] = colorsJson?.brandSecondary?.toColor ?? currentColors[.brandSecondary]
      currentColors[.contrast] = colorsJson?.contrast?.toColor ?? currentColors[.contrast]
      currentColors[.contrastSecondary] = colorsJson?.contrastSecondary?.toColor ?? currentColors[.contrastSecondary]
      currentColors[.negative] = colorsJson?.negative?.toColor ?? currentColors[.negative]
      currentColors[.negativeSecondary] = colorsJson?.negativeSecondary?.toColor ?? currentColors[.negativeSecondary]
      currentColors[.success] = colorsJson?.success?.toColor ?? currentColors[.success]
      currentColors[.successSecondary] = colorsJson?.successSecondary?.toColor ?? currentColors[.successSecondary]
      currentColors[.info] = colorsJson?.info?.toColor ?? currentColors[.info]
      currentColors[.infoSecondary] = colorsJson?.infoSecondary?.toColor ?? currentColors[.infoSecondary]
      currentColors[.warning] = colorsJson?.warning?.toColor ?? currentColors[.warning]
      currentColors[.warningSecondary] = colorsJson?.warningSecondary?.toColor ?? currentColors[.warningSecondary]
      currentColors[.error] = colorsJson?.error?.toColor ?? currentColors[.error]
      currentColors[.errorSecondary] = colorsJson?.errorSecondary?.toColor ?? currentColors[.errorSecondary]
      currentColors[.midpoint] = colorsJson?.midpoint?.toColor ?? currentColors[.midpoint]
      currentColors[.extra1] = colorsJson?.extra1?.toColor ?? currentColors[.extra1]
      currentColors[.extra2] = colorsJson?.extra2?.toColor ?? currentColors[.extra2]
   }

   static func applyDefaultColors() {
      let schemeName = OrganizationColorScheme.spasibka.colorScheme()
      let str = loadColorsCss(schemeName)
      let colors = parseCssColors(str)
      currentColors = colors
   }
}

private extension String {
   var toColor: UIColor? {
      UIColor(self)
   }
}

private extension ColorToken {
   var color: UIColor {
      if Self.currentColors.isEmpty {
         Self.recolor()
      }

      guard let color = Self.currentColors[self] else { fatalError() }

      return color
   }

   private static var currentColors: [ColorToken: UIColor] = [:]

   private static func parseCssColors(_ cssString: String) -> [ColorToken: UIColor] {
      let styleScheet = try? Stylesheet.parse(from: cssString)

      var colors = [ColorToken: UIColor]()

      styleScheet?.statements.forEach {
         switch $0 {
         case let .ruleSet(value):
            value.declarations.forEach {
               let property = $0.property
               let value = $0.value

               guard let key = ColorToken(rawValue: property) else { return }

               let color = UIColor(value)
               colors[key] = color
            }
         default:
            break
         }
      }

      return colors
   }

   private static func loadColorsCss(_ name: String) -> String {
      guard
         let filepath = Bundle.main.path(forResource: name, ofType: "css"),
         let contents = try? String(contentsOfFile: filepath)
      else { fatalError() }

      return contents
   }
}

extension UIColor {
   convenience init(_ hex: String, alpha: CGFloat = 1.0) {
      var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

      if hexFormatted.hasPrefix("#") {
         hexFormatted = String(hexFormatted.dropFirst())
      }

      assert(hexFormatted.count == 6, "Invalid hex code used.")

      var rgbValue: UInt64 = 0
      Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

      self.init(
         red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
         green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
         blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
         alpha: alpha
      )
   }

   // Generated by Bing Chat
   // Функция для затемнения цвета
   func darkenColor(_ amount: CGFloat) -> UIColor {
      // Проверяем, что аргумент в диапазоне от 0 до 1
      guard amount >= 0, amount <= 1 else {
         return self // возвращаем исходный цвет
      }

      // Получаем компоненты цвета в формате HSB
      var hue: CGFloat = 0
      var saturation: CGFloat = 0
      var brightness: CGFloat = 0
      var alpha: CGFloat = 0

      getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

      // Уменьшаем яркость на заданное значение
      brightness -= amount

      // Ограничиваем яркость в диапазоне от 0 до 1
      brightness = max(0, min(1, brightness))

      // Создаем новый цвет с обновленной яркостью и тем же оттенком, насыщенностью и прозрачностью
      return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
   }

   // Generated by Bing Chat
   // Функция для осветления цвета
   func lightenColor(_ amount: CGFloat) -> UIColor {
      // Проверяем, что аргумент в диапазоне от 0 до 1
      guard amount >= 0, amount <= 1 else {
         return self // возвращаем исходный цвет
      }

      // Получаем компоненты цвета в формате HSB
      var hue: CGFloat = 0
      var saturation: CGFloat = 0
      var brightness: CGFloat = 0
      var alpha: CGFloat = 0

      getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

      // Увеличиваем яркость на заданное значение
      brightness += amount

      // Ограничиваем яркость в диапазоне от 0 до 1
      brightness = max(0, min(1, brightness))

      // Создаем новый цвет с обновленной яркостью и тем же оттенком ,насыщенностью и прозрачностью
      return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
   }

   func contrastedColor(_ amount: CGFloat) -> UIColor {
      // Проверяем, что аргумент в диапазоне от 0 до 1
      var amount = amount < 0 ? 0 : amount
      amount = amount > 1 ? 1 : amount

      // Получаем компоненты цвета в формате HSB
      var hue: CGFloat = 0
      var saturation: CGFloat = 0
      var brightness: CGFloat = 0
      var alpha: CGFloat = 0

      getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

      // Увеличиваем яркость на заданное значение
      brightness += amount

      // Ограничиваем яркость в диапазоне от 0 до 1
      brightness = max(0, min(1, brightness))

      // Создаем новый цвет с обновленной яркостью и тем же оттенком ,насыщенностью и прозрачностью
      return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
   }
}
