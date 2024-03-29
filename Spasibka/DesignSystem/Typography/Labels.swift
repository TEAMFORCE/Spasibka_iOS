//
//  Labels.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 23.06.2022.
//

import StackNinja
import UIKit

protocol TypographyElements: InitProtocol, DesignElementable {
   // 8
   var medium8: DesignElement { get }
   var bold8: DesignElement { get }
   // 9
   var regular9: DesignElement { get }
   // 10
   var regular10: DesignElement { get }
   var medium10: DesignElement { get }
   // 12
   var regular12: DesignElement { get }
   var medium12: DesignElement { get }
   var regular12Secondary: DesignElement { get }
   var regular12Error: DesignElement { get }
   // 14
   var regular14: DesignElement { get }
   var semibold14: DesignElement { get }
   var bold14: DesignElement { get }
   var medium14: DesignElement { get }
   var regular14brand: DesignElement { get }
   var regular14error: DesignElement { get }
   var semibold14secondary: DesignElement { get }
   // 16
   var medium16: DesignElement { get }
   var semibold16: DesignElement { get }
   var regular16: DesignElement { get }
   var regular16Secondary: DesignElement { get }
   // 20
   var regular20: DesignElement { get }
   var semibold20: DesignElement { get }
   var medium20: DesignElement { get }
   var medium20invert: DesignElement { get }
   // 24
   var regular24: DesignElement { get }
   var bold24: DesignElement { get }
   var medium24: DesignElement { get }
   // 28
   var bold28: DesignElement { get }
   // 32
   var bold32: DesignElement { get }
   // 40
   var regular40: DesignElement { get }
   // 48
   var regular48: DesignElement { get }
   // 5
   var semibold54: DesignElement { get }

   var descriptionRegular8: DesignElement { get } // 400
   var descriptionRegular10: DesignElement { get } // 400
   var descriptionRegular12: DesignElement { get } // 400
   var descriptionRegular14: DesignElement { get } // 400
   var descriptionRegular16: DesignElement { get } // 400
   var descriptionRegualer64: DesignElement { get } // 400

   var descriptionMedium8: DesignElement { get } // 500
   var descriptionMedium10: DesignElement { get } // 500
   var descriptionMedium12: DesignElement { get } // 500
   var descriptionMedium14: DesignElement { get } // 500
   var descriptionMedium16: DesignElement { get  }// 500
   var descriptionMedium18: DesignElement { get } // 500
   var descriptionMedium20: DesignElement { get } // 500
   var descriptionMedium36: DesignElement { get } // 500
   var descriptionMedium64: DesignElement { get } // 500
   
   var descriptionBold36: DesignElement { get } // 700
   var descriptionBold48: DesignElement { get } // 700
   var descriptionBold64: DesignElement { get } // 700

   var labelRegular14: DesignElement { get } // 400
   var labelRegular16: DesignElement { get } // 400
   var labelRegularContrastColor14: DesignElement { get }
   var labelRegular10: DesignElement { get } // 400
   var descriptionSecondary12: DesignElement { get }
}

// MARK: - Labels Protocol

protocol LabelProtocol: TypographyElements where DesignElement == LabelModel {}

// MARK: - Labels

struct LabelBuilder<Design: DSP>: LabelProtocol, Designable {
   
   var medium8: DesignElement { .init(Design.state.label.medium8) }
   var bold8: DesignElement { .init(Design.state.label.bold8) }

   var regular9: LabelModel { .init(Design.state.label.regular9) }

   var regular10: LabelModel { .init(Design.state.label.regular10) }
   var medium10: LabelModel { .init(Design.state.label.medium10) }

   var regular12: LabelModel { .init(Design.state.label.regular12) }
   var medium12: LabelModel { .init(Design.state.label.medium12) }
   var regular12Secondary: LabelModel { .init(Design.state.label.regular12Secondary) }
   var regular12Error: LabelModel { .init(Design.state.label.regular12Error) }

   var regular14: LabelModel { .init(Design.state.label.regular14) }
   var semibold14: LabelModel { .init(Design.state.label.semibold14) }
   var bold14: LabelModel { .init(Design.state.label.bold14) }
   var medium14: LabelModel { .init(Design.state.label.medium14) }
   var regular14brand: LabelModel { .init(Design.state.label.regular14brand) }
   var regular14error: LabelModel { .init(Design.state.label.regular14error) }
   var semibold14secondary: LabelModel { .init(Design.state.label.semibold14secondary) }

   var regular16: LabelModel { .init(Design.state.label.regular16) }
   var regular16Secondary: LabelModel { .init(Design.state.label.regular16Secondary) }
   var medium16: LabelModel { .init(Design.state.label.medium16) }
   var semibold16: LabelModel { .init(Design.state.label.semibold16) }

   var regular20: LabelModel { .init(Design.state.label.regular20) }
   var semibold20: LabelModel { .init(Design.state.label.semibold20) }
   var medium20: LabelModel { .init(Design.state.label.medium20) }
   var medium20invert: LabelModel { .init(Design.state.label.medium20invert) }

   var regular24: LabelModel { .init(Design.state.label.regular24) }
   var bold24: LabelModel { .init(Design.state.label.bold24) }
   var medium24: LabelModel { .init(Design.state.label.medium24) }

   var bold28: LabelModel { .init(Design.state.label.bold28) }
   var bold32: LabelModel { .init(Design.state.label.bold32) }
   var regular40: LabelModel { .init(Design.state.label.regular40) }
   var regular48: LabelModel { .init(Design.state.label.regular48) }

   var semibold54: LabelModel { .init(Design.state.label.semibold54) }

   var descriptionRegular8: LabelModel { .init(Design.state.label.descriptionRegular8) }
   var descriptionRegular10: LabelModel { .init(Design.state.label.descriptionRegular10) }
   var descriptionRegular12: LabelModel { .init(Design.state.label.descriptionRegular12) }
   var descriptionRegular14: LabelModel { .init(Design.state.label.descriptionRegular14) }
   var descriptionRegular16: LabelModel { .init(Design.state.label.descriptionRegular16) }
   var descriptionRegualer64: LabelModel { .init(Design.state.label.descriptionRegualer64) }

   var descriptionMedium8: LabelModel { .init(Design.state.label.descriptionMedium8) }
   var descriptionMedium10: LabelModel { .init(Design.state.label.descriptionMedium10) }
   var descriptionMedium12: LabelModel { .init(Design.state.label.descriptionMedium12) }
   var descriptionMedium14: LabelModel { .init(Design.state.label.descriptionMedium14) }
   var descriptionMedium16: LabelModel { .init(Design.state.label.descriptionMedium16) }
   var descriptionMedium18: LabelModel { .init(Design.state.label.descriptionMedium18) }
   var descriptionMedium20: LabelModel { .init(Design.state.label.descriptionMedium20) }
   var descriptionMedium36: LabelModel { .init(Design.state.label.descriptionMedium36) }
   var descriptionMedium64: LabelModel { .init(Design.state.label.descriptionMedium64) }
   
   var descriptionBold36: LabelModel { .init(Design.state.label.descriptionBold36) }
   var descriptionBold48: LabelModel { .init(Design.state.label.descriptionBold48) }
   var descriptionBold64: LabelModel { .init(Design.state.label.descriptionBold64) }

   var labelRegular14: LabelModel { .init(Design.state.label.labelRegular14) }
   var labelRegular16: LabelModel { .init(Design.state.label.labelRegular16) }
   var labelRegularContrastColor14: LabelModel { .init(Design.state.label.labelRegularContrastColor14) }
   var labelRegular10: LabelModel { .init(Design.state.label.labelRegular10) }
   var descriptionSecondary12: LabelModel { .init(Design.state.label.descriptionSecondary12) }
}

protocol LabelStateProtocol: TypographyElements where DesignElement == [LabelState] {}

struct LabelStateBuilder<Design: DSP>: LabelStateProtocol, Designable {
   let fontBuilder = FontBuilder()

   var medium8: [LabelState] { [
      .font(fontBuilder.medium8),
      .textColor(Design.color.text),
   ] }

   var bold8: [LabelState] { [
      .font(fontBuilder.bold8),
      .textColor(Design.color.text),
   ] }

   var regular9: [LabelState] { [
      .font(fontBuilder.regular9),
      .textColor(Design.color.text),
   ] }

   var regular10: [LabelState] { [
      .font(fontBuilder.regular10),
      .textColor(Design.color.text),
   ] }

   var medium10: [LabelState] { [
      .font(fontBuilder.medium10),
      .textColor(Design.color.text),
   ] }

   var regular12: [LabelState] { [
      .font(fontBuilder.regular12),
      .textColor(Design.color.text),
   ] }

   var medium12: [LabelState] { [
      .font(fontBuilder.medium12),
      .textColor(Design.color.text),
   ] }

   var regular12Secondary: [LabelState] { [
      .font(fontBuilder.regular12Secondary),
      .textColor(Design.color.textSecondary),
   ] }

   var regular12Error: [LabelState] { [
      .font(fontBuilder.regular12Error),
      .textColor(Design.color.textError),
   ] }

   var regular14: [LabelState] { [
      .font(fontBuilder.regular14),
      .textColor(Design.color.text),
   ] }

   var semibold14: [LabelState] { [
      .font(fontBuilder.semibold14),
      .textColor(Design.color.text),
   ] }

   var bold14: [LabelState] { [
      .font(fontBuilder.bold14),
      .textColor(Design.color.text),
   ] }

   var medium14: [LabelState] { [
      .font(fontBuilder.medium14),
      .textColor(Design.color.text),
   ] }

   var regular14brand: [LabelState] { [
      .font(fontBuilder.regular14brand),
      .textColor(Design.color.textBrand),
   ] }

   var regular14error: [LabelState] { [
      .font(fontBuilder.regular14error),
      .textColor(Design.color.textError),
   ] }

   var semibold14secondary: [LabelState] { [
      .font(fontBuilder.semibold14secondary),
      .textColor(Design.color.textSecondary),
   ] }

   var regular16: [LabelState] { [
      .font(fontBuilder.regular16),
      .textColor(Design.color.text),
   ] }

   var regular16Secondary: [LabelState] { [
      .font(fontBuilder.regular16Secondary),
      .textColor(Design.color.textSecondary),
   ] }

   var medium16: [LabelState] { [
      .font(fontBuilder.medium16),
      .textColor(Design.color.text),
   ] }

   var semibold16: [LabelState] { [
      .font(fontBuilder.semibold16),
      .textColor(Design.color.text),
   ] }

   var regular20: [LabelState] { [
      .font(fontBuilder.regular20),
      .textColor(Design.color.text),
   ] }

   var semibold20: [LabelState] { [
      .font(fontBuilder.semibold20),
      .textColor(Design.color.text),
   ] }

   var medium20: [LabelState] { [
      .font(fontBuilder.medium20),
      .textColor(Design.color.text),
   ] }

   var medium20invert: [LabelState] { [
      .font(fontBuilder.medium20),
      .textColor(Design.color.textInvert),
   ] }

   var regular24: [LabelState] { [
      .font(fontBuilder.regular24),
      .textColor(Design.color.text),
   ] }

   var bold24: [LabelState] { [
      .font(fontBuilder.bold24),
      .textColor(Design.color.text),
   ] }

   var medium24: [LabelState] { [
      .font(fontBuilder.medium24),
      .textColor(Design.color.text),
   ] }

   var bold28: [LabelState] { [
      .font(fontBuilder.bold28),
      .textColor(Design.color.text),
   ] }

   var bold32: [LabelState] { [
      .font(fontBuilder.bold32),
      .textColor(Design.color.text),
   ] }

   var regular40: [LabelState] { [
      .font(fontBuilder.regular40),
      .textColor(Design.color.text),
   ] }

   var regular48: [LabelState] { [
      .font(fontBuilder.regular48),
      .textColor(Design.color.text),
   ] }

   var semibold54: [LabelState] { [
      .font(fontBuilder.semibold54),
      .textColor(Design.color.text),
   ] }

   var descriptionRegular8: [LabelState] { [
      .font(fontBuilder.descriptionRegular8),
      .textColor(Design.color.text)
   ] }

   var descriptionRegular10: [LabelState] { [
      .font(fontBuilder.descriptionRegular10),
      .textColor(Design.color.text)
   ] }

   var descriptionRegular12: [LabelState] { [
      .font(fontBuilder.descriptionRegular12),
      .textColor(Design.color.text)
   ] }
   
   var descriptionRegular14: [LabelState] { [
      .font(fontBuilder.descriptionRegular14),
      .textColor(Design.color.text)
   ] }

   var descriptionRegular16: [LabelState] { [
      .font(fontBuilder.descriptionRegular16),
      .textColor(Design.color.text)
   ] }
   
   var descriptionRegualer64: [LabelState] { [
      .font(fontBuilder.descriptionRegualer64),
      .textColor(Design.color.text)
   ] }

   var descriptionMedium8: [LabelState] { [
      .font(fontBuilder.descriptionMedium8),
      .textColor(Design.color.text),
   ] }

   var descriptionMedium10: [LabelState] { [
      .font(fontBuilder.descriptionMedium10),
      .textColor(Design.color.text),
   ] }

   var descriptionMedium12: [LabelState] { [
      .font(fontBuilder.descriptionMedium12),
      .textColor(Design.color.text),
   ] }

   var descriptionMedium14: [LabelState] { [
      .font(fontBuilder.descriptionMedium14),
      .textColor(Design.color.text)
   ] }

   var descriptionMedium16: [LabelState] { [
      .font(fontBuilder.descriptionMedium16),
      .textColor(Design.color.text)
   ] }

   var descriptionMedium18: [LabelState] { [
      .font(fontBuilder.descriptionMedium20),
      .textColor(Design.color.text)
   ] }
   
   var descriptionMedium20: [LabelState] { [
      .font(fontBuilder.descriptionMedium20),
      .textColor(Design.color.text)
   ] }

   var descriptionMedium36: [LabelState] { [
      .font(fontBuilder.descriptionMedium36),
      .textColor(Design.color.text)
   ] }
   
   var descriptionMedium64: [LabelState] { [
      .font(fontBuilder.descriptionMedium64),
      .textColor(Design.color.text)
   ] }
   
   var descriptionBold36: [LabelState] { [
      .font(fontBuilder.descriptionBold36),
      .textColor(Design.color.text)
   ] }
   
   var descriptionBold48: [LabelState] { [
      .font(fontBuilder.descriptionBold48),
      .textColor(Design.color.text)
   ]}
   
   var descriptionBold64: [LabelState] { [
      .font(fontBuilder.descriptionBold64),
      .textColor(Design.color.text)
   ] }
   
   var labelRegular14: [LabelState] { [
      .font(fontBuilder.labelRegular14),
      .textColor(Design.color.text),
   ] }
   
   var labelRegular16: [LabelState] { [
      .font(fontBuilder.labelRegular16),
      .textColor(Design.color.text)
   ] }
   
   var labelRegularContrastColor14: [LabelState] { [
      .font(fontBuilder.labelRegularContrastColor14),
      .textColor(Design.color.textContrastSecondary)
   ] }
   
   var labelRegular10: [LabelState] { [
      .font(fontBuilder.labelRegular10),
      .textColor(Design.color.text),
   ] }
   
   var descriptionSecondary12: [LabelState] { [
      .font(fontBuilder.descriptionSecondary12),
      .textColor(Design.color.textContrastSecondary)
   ] }
   
}
