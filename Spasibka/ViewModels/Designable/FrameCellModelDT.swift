//
//  FrameCellModel.swift
//  Spasibka
//
//  Created by Aleksandr Solovyev on 01.07.2022.
//

import StackNinja
import UIKit

enum FrameCellState {
   case text(String)
   case textColor(UIColor)
   case header(String)
   case caption(String)
   case burn(title: String)
   case hideBackImage(Bool)
   case hideBurnLabel
}

final class FrameCellModelDT<Design: DesignProtocol>: BaseViewModel<StackViewExtended>,
   Designable
{
   typealias State = StackState

   private let darkenColor = 0.23

   private lazy var backLogo = BalanceBackLogo<Design>(size: 160.aspected)
      .padding(.shift(.init(x: 40, y: -73)))

   private lazy var headerLabel = Design.label.descriptionRegular12
      .textColor(Design.color.textInvert)
   private lazy var textLabel = Design.label.descriptionBold64
      .textColor(Design.color.textInvert)
   private lazy var pluralCurrencyLabel = Design.label.descriptionRegular12
      .textColor(Design.color.textInvert)
   private lazy var currencyLabel = Design.label.descriptionRegular12
      .textColor(Design.color.textInvert)
   private lazy var captionLabel = Design.label.descriptionRegular12
      .textColor(Design.color.textInvert)
   private lazy var newBurnLabel = Design.label.descriptionRegular12
      .textColor(Design.color.textInvert)
      .numberOfLines(2)

   private let color: UIColor

   init(color: UIColor) {
      self.color = color
      super.init()
   }

   required init() {
      fatalError("init() has not been implemented")
   }

   override func start() {
      axis(.vertical)
      padding(.init(top: 20, left: 20, bottom: 14, right: 16))
      cornerCurve(.continuous)
      cornerRadius(Design.params.cornerRadiusSmall)
      addModel(backLogo/*.alpha(0.3)*/, setup: { $0.fitToView($1) })
      arrangedModels([
         headerLabel,
         Spacer(48),
         textLabel,
         pluralCurrencyLabel,
         Spacer(),
         captionLabel.righted(),
         newBurnLabel.righted(),
      ])
      gradient(
         .init(
            colors: [color,
                     color/*.darkenColor(darkenColor)*/],
            startPoint: .zero,
            endPoint: .init(x: 1, y: 0)
         ),
         size: .init(width: UIScreen.main.bounds.width / 2,
                     height: 245/*UIScreen.main.bounds.width / 2*/)
      )
      
      clipsToBound(true)
      maskToBounds(true)
   }
}

extension FrameCellModelDT: Stateable2 {
   func applyState(_ state: FrameCellState) {
      switch state {
      case let .text(string):
         textLabel.set(.text(string))
         if let amount = Int(string) {
            pluralCurrencyLabel.text(Design.text.pluralCurrencyForValue(amount, case: .genitive).capitalized)
         }
      case let .textColor(value):
         headerLabel.set(.textColor(value))
         textLabel.set(.textColor(value))
         captionLabel.set(.textColor(value))
         pluralCurrencyLabel.set(.textColor(value))
      case let .header(string):
         headerLabel.set(.text(string))
      case let .caption(string):
         captionLabel.set(.text(string))
      case let .burn(string):
         newBurnLabel.text(string)
      case let .hideBackImage(value):
         backLogo.hidden(value)
         gradient(
            .init(
               colors: [color,
                        color.darkenColor(darkenColor)],
               startPoint: .zero,
               endPoint: .init(x: 1, y: 0)
            ),
            size: .init(width: UIScreen.main.bounds.width / 2,
                        height: 245/*UIScreen.main.bounds.width / 2*/)
         )
      case .hideBurnLabel:
         newBurnLabel.size(.zero)
      }
   }
}

final class BalanceStatusFrameDT<Design: DSP>:
   StackNinja<SComboMRDD<ImageViewModel, LabelModel, LabelModel, ViewModel>>, Designable
{
   required init() {
      super.init()

      alignment(.center)
      cornerRadius(Design.params.cornerRadius)
      cornerCurve(.continuous)
      height(Design.params.infoFrameHeight)
      padding(.init(top: 8, left: 14, bottom: 8, right: 14))
      setMain {
         $0.size(.square(24))
      } setRight: {
         $0
            .set(Design.state.label.regular14)
            .padLeft(15)
      } setDown: {
         $0
            .set(Design.state.label.regular14)
            .padLeft(15)
      } setDown2: {
         $0
            .height(10)
      }
   }
}
